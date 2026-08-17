# LCRC Sermon Transcripts — Installation

## Prerequisites

| Requirement | Why | Notes |
|---|---|---|
| [Python 3.9+](https://www.python.org/downloads/) | Runs the pipeline | |
| [ffmpeg](https://ffmpeg.org/) | Whisper decodes audio through it | Must be on `PATH` |
| [Ollama](https://ollama.com/) | Generates the summaries | Must be running locally |
| [Git](https://git-scm.com/downloads) | Cloning the archive | |

## Install

```bash
git clone https://github.com/willtheorangeguy/LCRC-Sermon-Transcripts.git
cd LCRC-Sermon-Transcripts
pip install -r requirements.txt
pip install git+https://github.com/openai/whisper.git
```

## GPU acceleration

Whisper runs on the CPU by default, and on a full episode that is slow enough to matter. For an NVIDIA GPU, install the CUDA build of PyTorch instead:

```bash
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
```

This is the single change with the largest effect on how long a run takes.

## The Ollama model

```bash
ollama pull llama3.1:8b
```

Ollama must be running when the summarisation stage executes — it is contacted over HTTP on localhost, not embedded.

## What `requirements.txt` pulls in

| Package | Used for |
|---|---|
| `yt-dlp` | Downloading episode audio |
| `requests` | HTTP fetches for feeds and published transcripts |
| `openai-whisper` | Transcription |
| `transformers` | Tokenizer used to size summarisation chunks |
| `ollama` | Client for the local summarisation model |
| `language-tool-python` | Grammar and spelling cleanup |
| `torch` | Whisper's runtime — replace with the CUDA build for GPU |
| `mutagen` | Writing ID3 tags onto downloaded audio |

## Next

[Quickstart](./quickstart.md) to run one year, or [Configuration](./configuration.md) to change the models first.
