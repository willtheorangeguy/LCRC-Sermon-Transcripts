# LCRC Sermon Transcripts — Roadmap

Known gaps, observed from the code as it stands. This is a record of limitations, not a schedule — nothing here is committed work.

## Limitations

**Settings are hardcoded.** 6 values that a user might reasonably want to change — `whisper model`, `transcription language`, `ollama model`, `summary chunk size` — are literals inside the stage scripts. There is no config file, no environment variable, and no flag. Changing any of them means editing code and clearing a resume log.

**Resume logs record completion, not provenance.** A log entry says an item was processed; it does not say which model produced it or when. Re-running after changing a model therefore skips everything, and the only remedy is deleting the log and regenerating from scratch.

**No tests.** The pipeline has no automated verification. A stage that silently produces empty output would not be caught until someone read a transcript.

**Upstream layout is an unversioned dependency.** Feeds, publisher repositories, and page structures can change without notice, and the download stages have no contract to rely on. See [External Services](./api.md).

**Single language.** Transcription and grammar correction are both pinned to one locale, so multilingual episodes are transcribed as though they were not.

## Non-goals

- **Republishing.** This archive exists for search, accessibility, citation, and research. It is not a distribution channel — see [`CONTENT_LICENSE.md`](../CONTENT_LICENSE.md).
- **Authoritative transcripts.** Where the publisher provides their own, the pipeline prefers those; the generated ones are a fallback, not a replacement for the recording.
