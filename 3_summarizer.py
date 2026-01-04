"""
This script summarizes a transcript file by splitting it into manageable chunks,
summarizing each chunk using the Ollama API, and then combining the summaries into a final summary.
"""

import os
import sys
import ollama
from transformers import AutoTokenizer

# Log file name
LOG_FILENAME = "summarized.log"

# Load tokenizer
tokenizer = AutoTokenizer.from_pretrained("bert-base-uncased")


def split_text_by_tokens(text, max_tokens=2000):
    """Splits the input text into chunks that do not exceed the specified token limit."""
    words = text.split()
    chunks = []
    current_chunk = []

    # Split the text into words and process them
    for word in words:
        current_chunk.append(word)
        tokens = tokenizer(" ".join(current_chunk))["input_ids"]
        if len(tokens) > max_tokens:
            current_chunk.pop()
            chunks.append(" ".join(current_chunk))
            current_chunk = [word]

    if current_chunk:
        chunks.append(" ".join(current_chunk))

    return chunks


def summarize_chunk(text, model="llama3.1:8b"):
    """Summarizes a chunk of text using the specified Ollama model."""
    # Ollama prompt
    prompt = (
        "You are an expert summarizer. Summarize the following transcript into a short list "
        "of the main topics discussed or mentioned. Use only bullet points. "
        "Do not include any pleasantries to the user, or any sort of heading.\n\n"
        f"{text}"
    )

    # ollama response handler
    response = ollama.chat(
        model=model,
        messages=[
            {
                "role": "system",
                "content": "You summarize transcripts into concise topic overviews.",
            },
            {"role": "user", "content": prompt},
        ],
    )
    return response["message"]["content"]


def summarize_transcript(full_path, model):
    """Summarizes a single transcript file by splitting
    it into chunks and summarizing each chunk."""
    with open(full_path, "r", encoding="utf-8") as f:
        transcript = f.read()

    # Split the transcript into chunks
    print("Splitting transcript into chunks...")
    chunks = split_text_by_tokens(transcript)

    print(f"{len(chunks)} chunks created. Summarizing each...")

    # Summarize each chunk
    partial_summaries = []
    for i, chunk in enumerate(chunks):
        print(f"Summarizing chunk {i + 1}/{len(chunks)}...")
        summary = summarize_chunk(chunk, model)
        partial_summaries.append(summary)

    print("Generating final summary from chunk summaries...")

    # Combine partial summaries
    combined_summary = "\n".join(partial_summaries)

    # Save result
    base_name = os.path.splitext(full_path)[0]
    base_name = base_name.replace("_transcript", "")
    summary_path_txt = f"{base_name}_summary.txt"
    with open(summary_path_txt, "w", encoding="utf-8") as f:
        f.write(combined_summary)
    summary_path_md = f"{base_name}_summary.md"
    with open(summary_path_md, "w", encoding="utf-8") as f:
        f.write(combined_summary)

    print(f"Summary saved to: {summary_path_txt} and {summary_path_md}")


def summarize_transcripts(file_path, model="llama3.1:8b"):
    """Loops through all .txt files in the specified directory, skipping already processed files and summary files. Uses .inprogress tracking for resumability."""

    # Create a log file to track processed files
    log_path = os.path.join(file_path, LOG_FILENAME)
    processed_files = set()

    # Load already processed files from log
    if os.path.exists(log_path):
        with open(log_path, "r", encoding="utf-8") as log_file:
            processed_files = set(line.strip() for line in log_file if line.strip())

    # Loop through all .txt files in the directory
    for file in os.listdir(file_path):
        full_path = os.path.join(file_path, file)
        # Skip summary files and already processed or in-progress files
        if (
            file.endswith(".txt")
            and not file.endswith("_summary.txt")
            and not file.endswith("_corrected.txt")
            and file not in processed_files
        ):
            print(f"Processing {file}...")
            try:
                summarize_transcript(full_path, model)
                # Mark as processed
                with open(log_path, "a", encoding="utf-8") as log_file:
                    log_file.write(file + "\n")
                    log_file.flush()
            # Catch any exceptions and report failure
            except Exception as e:
                print(f"Error summarizing {file}: {e}")
                print(f"Skipping {file} and continuing to next file.\n")
                continue

# When script is run, summarize all transcripts in the current directory
if __name__ == "__main__":
    summarize_transcripts(sys.argv[1] if len(sys.argv) > 1 else os.getcwd())
