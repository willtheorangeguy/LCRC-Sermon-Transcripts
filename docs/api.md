# LCRC Sermon Transcripts — External Services

This repository exposes no API. It **consumes** several, and they are the parts most likely to break a run, so they are listed here.

| Service | Reached via | Used for | Fails when |
|---|---|---|---|
| Publisher audio | `yt-dlp` | Downloading episode media | The publisher changes URLs, or `yt-dlp` is out of date |
| RSS feed | `requests` / `urllib` | Episode titles, dates, track numbers | The feed moves or stops publishing older episodes |
| Ollama | HTTP on localhost | Summarisation | Ollama is not running, or the model has not been pulled |
| LanguageTool | Local Java process, started by the library | Grammar and spelling correction | No Java runtime is available |

## Nothing here is authenticated except where noted

Ollama and LanguageTool run locally. Feeds and publisher repositories are public. That means the pipeline needs no secrets to run — and also that it is entirely at the mercy of upstream layout changes, with no contract or versioning to rely on.

## Ollama in particular

Summarisation talks to Ollama over HTTP rather than embedding a model. Ollama has to be **running** and the model has to be **pulled** — see [Configuration](./configuration.md) for which one. A missing model fails every episode identically rather than degrading, which at least makes it obvious.
