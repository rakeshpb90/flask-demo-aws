import os
from datetime import datetime
from github import Github, GithubException
from git import Repo, GitCommandError
from ruamel.yaml import YAML
import sys
import shutil 
import subprocess
# def update_image_tag(file_path, image_tag):
#     """
#     Update the 'tag' under the 'image' section in a YAML file.

#     Args:
#         file_path (str): Path to the YAML file.
#         image_tag (str): New image tag.

#     Raises:
#         FileNotFoundError: If the YAML file does not exist.
#     """
#     yaml = YAML()
#     try:
#         with open(file_path, 'r') as file:
#             data = yaml.load(file)
#     except FileNotFoundError:
#         print(f"Error: YAML file '{file_path}' not found.")
#         sys.exit(1)

#     # Ensure the 'image' section exists
#     if 'image' not in data:
#         data['image'] = {}

#     # Update the 'tag' under the 'image' section
#     data['image']['tag'] = image_tag

#     with open(file_path, 'w') as file:
#         # Dump the data back to the file preserving comments
#         yaml.dump(data, file)

def update_image_tag(file_path, image_tag):
    try:
        # Execute the first yq command to retrieve the current image tag
        current_image_tag = subprocess.check_output(['yq', 'e', '.image.tag', file_path]).decode().strip()

        print(f"INFO: Current image tag: {current_image_tag}")

        # Execute the second yq command to update the image tag in the values file
        subprocess.run(['yq', 'e', f".image.tag = \"{image_tag}\"", '-i', file_path])

        print("INFO: Image tag updated successfully.")
    except FileNotFoundError:
        print(f"Error: YAML file '{file_path}' not found.")

def commit_and_push_changes(repo, commit_message, file_path, branch_name, image_tag):
    branch = repo.heads.main  # Replace "main" with your main branch name
    print(f"Branch name: {branch_name}")
    print(f"File path: {file_path}")
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
        try:
            origin = repo.remote(name='origin')
            origin.push(refspec=f"refs/heads/{branch_name}:refs/heads/{branch_name}")
            print(f"Changes pushed to branch {branch_name}")
        except Exception as e:
            print(f"Error: Failed to push changes - {e}")
            sys.exit(1)        
    else:
        print("No changes detected. Skipping commit and push.")
        sys.exit()
    return new_branch

def create_pull_request(github_repo, base_branch, compare_branch, title, body):
    """
    Create a pull request on a GitHub repository.

    Args:
        github_repo (github.Repository.Repository): GitHub repository object.
        base_branch (str): Base branch for the pull request.
        compare_branch (str): Branch to compare against.
        title (str): Title of the pull request.
        body (str): Body content of the pull request.

    Returns:
        github.PullRequest.PullRequest: Created pull request object.
    """
    print(f"Base branch: {base_branch}")
    print(f"Compare branch: {compare_branch}")

    try:
        pull_request = github_repo.create_pull(base=base_branch, head=compare_branch, title=title, body=body)
        print("Pull request created successfully.")
        return pull_request
    except GithubException as e:
        print(f"Error: Failed to create pull request - {e}")
        sys.exit(1)

def main():
    github_token = os.getenv('GITHUB_TOKEN')
    print(github_token)
    github_repo_owner = os.getenv('GITHUB_REPO_OWNER')
    github_repo_name = os.getenv('GITHUB_REPO_NAME')
    app_name = os.getenv('APP')  
    image_name = os.getenv('IMAGE_NAME') 
    env_name = os.getenv('ENV_NAME') 
    local_directory = os.getenv("CODEBUILD_SRC_DIR")
    main_branch = "main"
    
    if not all([github_token, github_repo_owner, github_repo_name]):
        print("Error: Please provide valid GitHub credentials in environment variables.")
        sys.exit(1)


    clone_path = os.path.join(local_directory, "tmp", "repo_clone")

    if os.path.exists(clone_path):
        shutil.rmtree(clone_path)
            
    # Create clone path directory if it doesn't exist
    if not os.path.exists(clone_path):
        os.makedirs(clone_path)

    repo_url = f"https://{github_token}@github.com/{github_repo_owner}/{github_repo_name}.git"
    repo = Repo.clone_from(repo_url, clone_path)
    github = Github(github_token)
    github_repo = github.get_user(github_repo_owner).get_repo(github_repo_name)
    
    # Update Helm values file
    file_path = os.path.join(env_name, app_name, "values.yaml")
    helm_values_path = os.path.join(clone_path, file_path)
    print(f"Helm value for app - {app_name} : {helm_values_path}")

    # Commit and push changes to a new branch
    timestamp_str = datetime.now().strftime("%Y%m%d%H%M%S")
    branch_name = f"{app_name}-{timestamp_str}"
    commit_message = f"{app_name} | Update Helm values file for the app {app_name} with new image tag {image_name}"
    new_branch = commit_and_push_changes(repo, commit_message, helm_values_path, branch_name, image_name)

    # Create a pull request
    pull_request_title = f"Update Helm values file for the app {app_name} with new image tag {image_name}"
    pull_request_body = f"This pull request updates the Helm values file with the new image tag of the app - {app_name}"
    pr = create_pull_request(github_repo, main_branch, new_branch.name, pull_request_title, pull_request_body)

if __name__ == "__main__":
    main()
