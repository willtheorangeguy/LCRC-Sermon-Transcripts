# LCRC Sermon Transcripts — Documentation

This archive holds machine-generated transcripts and summaries for the Ladner CRC sermons, together with the pipeline that produces them. The pipeline runs as 5 numbered stages; `main.py` executes them in order.

```
LCRC-Sermon-Transcripts/
├── docs/
│   ├── README.md          this page
│   ├── quickstart.md      shortest path to one finished episode
│   ├── installation.md    prerequisites, GPU build, dependencies
│   ├── configuration.md   the hardcoded knobs and where they live
│   ├── architecture.md    data flow, layout, resumability
│   ├── api.md             external services this depends on
│   ├── usage.md           running it day to day
│   ├── pipeline.md        what each numbered stage does
│   ├── faq.md             licensing, accuracy, speed
│   ├── troubleshooting.md concrete failures and fixes
│   └── roadmap.md         known gaps and non-goals
├── main.py            runs every stage in order
├── 1_download.py
├── 2_tagger.py
├── 3_transcriber.py
├── 4_summarizer.py
├── 5_cleanup.py
├── 2020/
├── 2021/
├── 2022/
├── 2023/
├── 2024/
├── 2025/
└── requirements.txt
```

## Pages

- [Quickstart](./quickstart.md) — install, pull a model, transcribe one year
- [Installation](./installation.md) — prerequisites, GPU acceleration, dependencies
- [Configuration](./configuration.md) — models, language, chunk size, and which file each lives in
- [Architecture](./architecture.md) — data flow, on-disk layout, how resumability works
- [External services](./api.md) — what this depends on that it does not control
- [Usage](./usage.md) — running the pipeline and the helper scripts
- [Pipeline](./pipeline.md) — what each stage does and what it writes
- [FAQ](./faq.md) — licensing, accuracy, speed, regenerating output
- [Troubleshooting](./troubleshooting.md) — concrete failures and their causes
- [Roadmap](./roadmap.md) — known limitations and deliberate non-goals

## Before reusing the transcripts

The code is MIT. The transcript text is not — see [`CONTENT_LICENSE.md`](../CONTENT_LICENSE.md).
