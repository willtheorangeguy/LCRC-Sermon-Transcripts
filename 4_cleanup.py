"""
This script processes all .txt and .md files in the current directory,
correcting their grammar and spelling using LanguageTool.
"""

import os
import sys
import language_tool_python

# Log file name
LOG_FILENAME = "cleaned.log"

# Chunk size for processing large files
CHUNK_SIZE = 10000

# Initialize the tool
tool = language_tool_python.LanguageTool('en-CA')

def split_text_into_chunks(text, chunk_size=CHUNK_SIZE):
    """Splits text into chunks at natural break points."""
    chunks = []
    start = 0
    text_length = len(text)
    
    while start < text_length:
        # Determine the end of this chunk
        end = start + chunk_size
        
        # If this is the last chunk, just take the rest
        if end >= text_length:
            chunks.append(text[start:])
            break    
     
        # Try to break at a single newline
        newline_break = text.rfind('\n', start, end)
        if newline_break != -1 and newline_break > start:
            chunks.append(text[start:newline_break + 1])
            start = newline_break + 1
            continue
        
        # Try to break at a sentence boundary
        sentence_break = max(
            text.rfind('. ', start, end),
            text.rfind('? ', start, end),
            text.rfind('! ', start, end)
        )
        if sentence_break != -1 and sentence_break > start:
            chunks.append(text[start:sentence_break + 2])
            start = sentence_break + 2
            continue
        
        # If no natural break found, just split at chunk_size
        chunks.append(text[start:end])
        start = end
    
    return chunks

def correct_text_in_chunks(text, chunk_size=CHUNK_SIZE):
    """
    Corrects text by processing it in chunks to improve performance.
    Returns the corrected text and the total number of corrections made.
    """
    chunks = split_text_into_chunks(text, chunk_size)
    corrected_chunks = []
    total_corrections = 0
    
    print(f"  Processing {len(chunks)} chunk(s)...")
    
    for i, chunk in enumerate(chunks, 1):
        print(f"    Chunk {i}/{len(chunks)}...", end='', flush=True)
        matches = tool.check(chunk)
        total_corrections += len(matches)
        
        if matches:
            corrected_chunk = tool.correct(chunk)
            corrected_chunks.append(corrected_chunk)
            print(f" {len(matches)} corrections")
        else:
            corrected_chunks.append(chunk)
            print(" no corrections needed")
    
    return ''.join(corrected_chunks), total_corrections

def clean_text_file(file_path):
    """Cleans text files by correcting grammar and spelling errors using LanguageTool, with logging."""
    # Path to log file
    log_path = os.path.join(file_path, LOG_FILENAME)
    cleaned_files = set()

    # Load already cleaned files from log
    if os.path.exists(log_path):
        with open(log_path, "r", encoding="utf-8") as log_file:
            for line in log_file:
                cleaned_files.add(line.strip())

    with open(log_path, "a", encoding="utf-8") as log_file:
        # Loop through all .txt and .md files in the directory
        for file in os.listdir(file_path):
            if (
                (file.endswith(".txt") or file.endswith(".md"))
                and not file.endswith("_corrected.txt")
                and not file.endswith("_corrected.md")
            ):
                # Skip already cleaned files
                if file in cleaned_files:
                    print(f"⏭️ Skipping (already cleaned): {file}")
                    continue
                full_path = os.path.join(file_path, file)
                print(f"Processing {full_path}...")

                # Read file content
                try:
                    with open(full_path, "r", encoding="utf-8") as f:
                        content = f.read()
                    
                    # Use chunked processing for better performance
                    corrected_content, total_corrections = correct_text_in_chunks(content)
                    
                    if total_corrections > 0:
                        print(f"  Total: {total_corrections} correction(s) made in {file}")
                        corrected_path = full_path.replace(".txt", "_corrected.txt").replace(".md", "_corrected.md")
                        with open(corrected_path, "w", encoding="utf-8") as f:
                            f.write(corrected_content)
                        print(f"  Saved corrected version to {os.path.basename(corrected_path)}\n")
                    else:
                        print(f"  No corrections needed for {file}.\n")
                    
                    # Log this file as cleaned
                    log_file.write(file + "\n")
                    log_file.flush()
                
                # Handle specific file read/write errors
                except (FileNotFoundError, PermissionError, UnicodeDecodeError, OSError) as e:
                    print(f"Error processing {file}: {e}")
                    print(f"Skipping {file} and continuing to next file.\n")
                    continue
                
                # Handle any other unexpected errors
                except Exception as e:
                    print(f"Unexpected error processing {file}: {e}")
                    print(f"Skipping {file} and continuing to next file.\n")
                    continue

if __name__ == "__main__":
    clean_text_file(sys.argv[1] if len(sys.argv) > 1 else os.getcwd())