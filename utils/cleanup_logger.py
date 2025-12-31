"""Utility to log text file names from a specified folder into 'cleaned.log'."""

import os
import sys

def log_text_files(folder_path):
    """Logs names of text files in the specified folder to 'cleaned.log'."""
    log_file = "cleaned.log"
    folder_path = "../" + folder_path # move one directory up

    if not os.path.isdir(folder_path):
        print(f"Folder not found: {folder_path}")
        return

    # Write matching filenames to log file
    log_file_path = os.path.join(folder_path, log_file)
    with open(log_file_path, "a", encoding="utf-8") as f:
        for entry in os.scandir(folder_path):
            if entry.name.endswith("_summary.txt") or entry.name.endswith("_summary.md") or entry.name.endswith("_transcript.txt") or entry.name.endswith("_transcript.md"):
                f.write(entry.name + "\n")

    print(f"Finished. Matching filenames have been written to {log_file}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        folder = input("Enter the folder path to scan for text files: ").strip()
    else:
        folder = sys.argv[1]

    log_text_files(folder)
