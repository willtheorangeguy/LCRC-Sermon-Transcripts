# LCRC Sermon Transcripts — Quickstart

The shortest path from an empty checkout to one transcribed, summarised episode. For every install option and prerequisite, see [Installation](./installation.md).

## 1. Install

```bash
git clone https://github.com/willtheorangeguy/LCRC-Sermon-Transcripts.git
cd LCRC-Sermon-Transcripts
pip install -r requirements.txt
pip install git+https://github.com/openai/whisper.git
```

You also need [ffmpeg](https://ffmpeg.org/) on your `PATH` and [Ollama](https://ollama.com/) running locally.

## 2. Pull the summarisation model

```bash
ollama pull llama3.1:8b
```

The summarisation stage calls Ollama over HTTP and fails if the model has not been pulled. This is the most common first-run failure.

## 3. Run one year

```bash
python main.py 2025
```

## What to expect

- Audio downloads first, then transcription, then summarisation, then grammar cleanup.
- **Transcription is the slow part.** On CPU it can take longer than the episode itself. See [Installation](./installation.md) for the CUDA build of PyTorch.
- Each stage appends to a log as it finishes an item, so interrupting and re-running resumes rather than starting over.
- Output lands beside the audio: a transcript, a summary, and a corrected transcript.

If something fails, [Troubleshooting](./troubleshooting.md) covers the usual causes.
