#Author Piotr Tarnawski
#angrysysops.com
# X: -> @TheTechWorldPod

import os

def scan_folder(path: str) -> None:
    try:
        entries = os.listdir(path)
    except FileNotFoundError:
        print("Error: that path does not exist.")
        return

    print(f"\nContents of: {path}\n")    
    for name in entries:
        full_path= os.path.join(path, name)
        label = "DIR" if os.path.isdir(full_path) else "FILE"
        print(f"[{label}] {name}")

if __name__ == "__main__":
    target = input("Enter a folder path to explore: ")
    scan_folder(target)
