# LCRC Sermon Transcripts — Configuration

There are no environment variables, config files, or command-line flags. Every setting below is a **literal inside a stage script**, which is precisely why it is worth listing — changing behaviour means editing code, and knowing which line saves you reading all of it.

## Settings

| Setting | Current value | Defined in | Why it matters |
|---|---|---|---|
| Whisper model | `turbo` | `3_transcriber.py` | Accuracy against transcription speed and VRAM |
| Transcription language | `en` | `3_transcriber.py` | Whisper is pinned to this language rather than detecting it |
| Ollama model | `llama3.1:8b` | `4_summarizer.py` | Summary quality; must already be pulled in Ollama |
| Summary chunk size | `2000 tokens` | `4_summarizer.py` | How much context each summarisation pass sees |
| Chunking tokenizer | `bert-base-uncased` | `4_summarizer.py` | Only used to measure chunk length, not to generate text |
| Grammar locale | `en-CA` | `5_cleanup.py` | Which spelling conventions the cleanup stage enforces |

## Notes on the ones that bite

**Whisper model (`turbo`).** Larger models transcribe more accurately and more slowly, and need more VRAM. If transcription fails with an out-of-memory error, this is the line to change in `3_transcriber.py`.

**Ollama model (`llama3.1:8b`).** Must be pulled in Ollama before the stage runs — `ollama pull` it, or summarisation fails for every episode rather than degrading.

**Language (`en`).** Whisper is pinned rather than auto-detecting. That is faster and more reliable for a single-language show, and wrong for anything multilingual.

**Grammar locale (`en-CA`).** Decides which spellings the cleanup stage treats as errors. Changing it rewrites the corrected transcripts accordingly.

**Chunk size (`2000 tokens`).** Transcripts are split into chunks, each summarised separately, and the summaries then combined. Larger chunks give the model more context per pass but risk exceeding what it handles well.

## Changing a setting safely

Stages skip work already recorded in their log, so editing a model and re-running does **not** regenerate existing output. Delete the relevant log first — see [Pipeline](./pipeline.md).
