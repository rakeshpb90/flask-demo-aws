import os

def check_directories_exist(directories):
    current_directory_contents = os.listdir('.')
    existing_directories = []

    for directory in directories:
        if directory in current_directory_contents and os.path.isdir(directory):
            existing_directories.append(directory)

    return existing_directories

def main():
    directories_to_check = [
    ]

    existing_directories = check_directories_exist(directories_to_check)

    if existing_directories:
        print("The following directories exist in the current directory:")
        for directory in existing_directories:
            print(directory)
    else:
        print("None of the specified directories exist in the current directory.")

if __name__ == "__main__":
    main()
