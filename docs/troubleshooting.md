# LCRC Sermon Transcripts — Troubleshooting

## Summarisation fails for every episode

Almost always Ollama. Check both halves:

```bash
ollama list          # is the model pulled?
ollama pull llama3.1:8b
ollama ps            # is the server running?
```

Summarisation talks to Ollama over HTTP. If the server is down or the model is absent, every episode fails the same way rather than some succeeding.

## `ffmpeg not found` during transcription

Whisper shells out to ffmpeg to decode audio. Install it and make sure it is on `PATH` — a Python package will not substitute.

## CUDA out of memory

The Whisper model is set to `turbo`. Larger models need more VRAM. Either switch to a smaller one or let it fall back to CPU — [Configuration](./configuration.md) has the line to edit.

## Transcription is extremely slow

Expected on CPU. Install the CUDA build of PyTorch — see [Installation](./installation.md). Note that PyTorch installed for CPU will silently stay on CPU even with a working GPU present; the index URL matters.

## A stage says there is nothing to do

Its resume log already lists the items. That is the mechanism that makes long runs interruptible, and it also means edited settings do not trigger a rebuild. Delete the log to force one — [Pipeline](./pipeline.md) lists which log belongs to which stage.

## Downloads fail or return nothing

Publishers move feeds and change URL formats. Update `yt-dlp` first, since it changes most often:

```bash
pip install --upgrade yt-dlp
```

If that does not help, the feed or repository the download stage targets has probably moved — see [External Services](./api.md).

## LanguageTool fails to start

`language-tool-python` starts a local Java process. Without a Java runtime the cleanup stage cannot run; the earlier stages are unaffected, so transcripts and summaries still get produced.
