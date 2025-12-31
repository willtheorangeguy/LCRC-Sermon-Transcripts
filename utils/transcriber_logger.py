"""Utility to log audio file names from a specified folder into 'transcribed.log'."""

import os
import sys

def log_audio_files(folder_path):
    """Logs names of audio files in the specified folder to 'transcribed.log'."""
    log_file = "transcribed.log"
    folder_path = "../" + folder_path # move one directory up

    if not os.path.isdir(folder_path):
        print(f"Folder not found: {folder_path}")
        return

    # Write matching filenames to log file
    log_file_path = os.path.join(folder_path, log_file)
    with open(log_file_path, "a", encoding="utf-8") as f:
        for entry in os.scandir(folder_path):
            if entry.is_file():
                _, ext = os.path.splitext(entry.name)
                if ext.lower() == ".mp3":
                    f.write(entry.name + "\n")

    print(f"Finished. Matching filenames have been written to {log_file}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        folder = input("Enter the folder path to scan for audio files: ").strip()
    else: 
        folder = sys.argv[1]
    
    log_audio_files(folder)
