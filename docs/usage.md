# LCRC Sermon Transcripts — Usage

## Prerequisites

| Requirement | Why |
|---|---|
| [Python 3.9+](https://www.python.org/downloads/) | Runs the pipeline |
| [ffmpeg](https://ffmpeg.org/) | Audio decoding for Whisper |
| [Ollama](https://ollama.com/) | Local model that writes the summaries |
| [Git](https://git-scm.com/downloads) | Cloning the archive |

## Install

```bash
git clone https://github.com/willtheorangeguy/LCRC-Sermon-Transcripts.git
cd LCRC-Sermon-Transcripts
pip install -r requirements.txt
pip install git+https://github.com/openai/whisper.git
```

Whisper runs on the CPU by default, which is slow. For NVIDIA GPUs, install the CUDA build of PyTorch instead:

```bash
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
```

## Running the pipeline

```bash
python main.py <show> <year>
```

`main.py` runs every stage in sequence for one show and one year.

### Shows

- `2020`
- `2021`
- `2022`
- `2023`
- `2024`
- `2025`

Stages are also runnable individually when only part of the work needs redoing — see [`pipeline.md`](./pipeline.md).

## Helper scripts

PowerShell utilities that sit alongside the pipeline:

| Script | Purpose |
|---|---|
| `archive.ps1` | Define the current year to skip |
| `autocommit.ps1` | Set strict mode to catch errors |
| `hf.ps1` | $PrettyName |
| `hfall.ps1` | All LCRC Sermon Transcripts |

## Output layout

Each episode produces an audio file, a transcript, and a summary in its show and year folder. Stages write a log file (`transcribed.log`, `summarized.log`, `cleaned.log`) recording what they have already processed, so re-running a stage skips completed work rather than repeating it.
