import json
from github import Github
from ruamel.yaml import YAML
from datetime import datetime
from git import Repo
import os
import shutil
import sys


def update_image_tag(file_path, image_tag):
    yaml = YAML()
    with open(file_path, 'r') as file:
        data = yaml.load(file)

    # Ensure the 'image' section exists
    if 'image' not in data:
        data['image'] = {}

    # Update the 'tag' under the 'image' section
    data['image']['tag'] = image_tag

    with open(file_path, 'w') as file:
        # Dump the data back to the file preserving comments
        yaml.dump(data, file)

def commit_and_push_changes(repo, commit_message, file_path, branch_name, image_tag):
    branch = repo.heads.main  # Replace "main" with your main branch name
    print(f"branch name - {branch_name}")
    print(file_path)
    # Create a new branch
    new_branch = repo.create_head(branch_name)
    new_branch.checkout()
    update_image_tag(file_path, image_tag)

    # Stage the changes
    repo.index.add([file_path])
    
    # Check if there are differences
    diff = repo.index.diff("HEAD")
    print(diff)
    if diff:
        # Stage, commit, and push changes to the new branch
        repo.index.commit(commit_message)
        origin = repo.remote(name='origin')
        origin.push(refspec=f"refs/heads/{branch_name}:refs/heads/{branch_name}")
        print(f"Changes pushed to branch {branch_name}")
    else:
        print("No changes detected. Skipping commit and push.")
        sys.exit()
    return new_branch

def create_pull_request(github_repo, base_branch, compare_branch, title, body):
    # Create a pull request
    print(base_branch)
    print(compare_branch)
    
    pull_request = github_repo.create_pull(base=base_branch, head=compare_branch, title=title, body=body)
    return pull_request

def perform_merge(git_repo, pr_number):
    pull_request = git_repo.get_pull(pr_number)
    pull_request.merge()
    print(f"Pull Request #{pr_number} merged successfully.")
    return pull_request

def create_tag(git_repo, tag_name, tag_message, commit_sha):
    tag = git_repo.create_tag(tag_name, ref=commit_sha, message=tag_message, force=True)
    print(f"Tag '{tag_name}' created successfully.")
    return tag

def lambda_handler(event, context):
    
    repository_name = event['detail']['repository-name']
    image_tag = event['detail']['image-tag']

    # Read GitHub credentials from environment variables
    github_token = os.getenv('GITHUB_TOKEN')
    github_repo_owner = os.getenv('GITHUB_REPO_OWNER')
    github_repo_name = os.getenv('GITHUB_REPO_NAME')
    # Validate environment variables
    if not all([github_token, github_repo_owner, github_repo_name]):
        print("Error: Please provide valid GitHub credentials in environment variables.")
        return

    local_directory = "/tmp/repo_clone"
    # Remove the existing directory if it exists
    if os.path.exists(local_directory):
        shutil.rmtree(local_directory)

    # Clone the GitHub repository
    repo_url = f"https://{github_token}@github.com/{github_repo_owner}/{github_repo_name}.git"
    repo = Repo.clone_from(repo_url, local_directory)
    github = Github(github_token)
    github_repo = github.get_user(github_repo_owner).get_repo(github_repo_name)

    # Update Helm values file
    file_path = f'qa/{repository_name}/values.yaml'
    helm_values_path = f'{local_directory}/{file_path}'

    # Commit and push changes to a new branch
    timestamp_str = datetime.now().strftime("%Y%m%d%H%M%S")
    branch_name = f"{repository_name}-{timestamp_str}"
    commit_message = f"{repository_name} | Update Helm values file with new image tag ({image_tag})"
    new_branch = commit_and_push_changes(repo, commit_message, helm_values_path, branch_name, image_tag)

    # Create a pull request
    pull_request_title = f"Update Helm values file with new image tag ({image_tag})"
    pull_request_body = f"This pull request updates the Helm values file with the new image tag of the app {repository_name}"
    pr = create_pull_request(github_repo, "main", new_branch.name, pull_request_title, pull_request_body)

    # Merge the pull request
    if pr.number:
        merged_pr = perform_merge(github_repo, pr.number)

