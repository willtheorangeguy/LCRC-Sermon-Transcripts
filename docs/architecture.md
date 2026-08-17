# LCRC Sermon Transcripts — Architecture

A linear batch pipeline. There is no service, no database, and no state beyond files on disk — which is the point: every intermediate result is inspectable, and any stage can be re-run on its own.

## Data flow

```
  RSS feed / publisher site
            │
            ▼
  1_download.py       
            ▼
  2_tagger.py           → tagged.log
            ▼
  3_transcriber.py      → transcribed.log
            ▼
  4_summarizer.py       → summarized.log
            ▼
  5_cleanup.py          → cleaned.log
            │
            ▼
  <show>/<year>/*.mp3, *_transcript.md, *_summary.md
```

Each stage reads what the previous one wrote and adds files alongside it. Nothing is deleted or overwritten in place, so a failed run leaves partial output rather than corrupt output.

## On-disk layout

```
LCRC-Sermon-Transcripts/
├── 2020/
│   └── <year>/
│       ├── <episode>.mp3
│       ├── <episode>_transcript.md
│       └── <episode>_summary.md
├── ... 5 more show directories
├── main.py
├── <n>_*.py            pipeline stages
├── *.log               resume logs, one per expensive stage
└── requirements.txt
```

## Why the numbered filenames

Ordering is encoded in the filenames rather than in a config file or a DAG. `main.py` reads the list, runs each in turn, and passes through the arguments it was given. Adding a stage means adding a numbered script and listing it — there is no framework to learn, and the execution order is visible from `ls`.

## State and resumability

The only persistent state is the log files. Each expensive stage appends an identifier as it completes an item and skips anything already listed:

| Log | Written by |
|---|---|
| `tagged.log` | `2_tagger.py` |
| `transcribed.log` | `3_transcriber.py` |
| `summarized.log` | `4_summarizer.py` |
| `cleaned.log` | `5_cleanup.py` |

This is what makes a multi-hour run interruptible. It also means **stages will not redo work after you change a setting** — the log does not record which model produced a result, only that one exists. Delete the log to force a rebuild.

## Separation of concerns

| Concern | Where |
|---|---|
| Acquisition | `1_download.py`, `downloader.py` |
| Metadata | tagging stage |
| Machine learning | transcription and summarisation stages |
| Text correction | cleanup stage |
| Orchestration | `main.py` — argument passing and sequencing only |

`main.py` holds no logic beyond the order of the stages, so it rarely needs to change.
