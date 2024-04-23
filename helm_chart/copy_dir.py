import shutil

def copy_file_to_directories(file_path, directories):
    for directory in directories:
        destination_path = directory + "/" + file_path.split("/")[-1]   
        shutil.copy(file_path, destination_path)
        print(f"File copied to {destination_path}")

# Example usage:
file_to_copy = "ingress.yaml"
list_of_directories = ["path/to/destination/dir1", "path/to/destination/dir2", "path/to/destination/dir3"]

copy_file_to_directories(file_to_copy, list_of_directories)
