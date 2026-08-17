# LCRC Sermon Transcripts — FAQ

## Can I reuse these transcripts?

Not under the repository's code licence. The pipeline is MIT; the transcript text is not. It is machine-generated from recordings of the Ladner CRC sermons, and those words belong to the speakers and rights holders. Read [`CONTENT_LICENSE.md`](../CONTENT_LICENSE.md) before republishing, redistributing, or building anything on it. Quoting with attribution to the original work is ordinary practice and unaffected.

## How accurate are they?

Accurate enough to search, not accurate enough to quote without checking. Whisper misrenders names, technical terms, and crosstalk in particular. The summaries are a further lossy step on top of that. Where accuracy matters, go to the original recording.

## Why is a transcript missing for an episode I can see?

Most likely the pipeline has not been run for that year, or the stage failed partway and its resume log records the episodes that did succeed. Re-running is safe — completed work is skipped. See [Pipeline](./pipeline.md).

## I removed a file and re-running did not regenerate it.

The resume log still lists it. Stages consult the log, not the filesystem. Delete the relevant `.log` entry or the whole log — see [Pipeline](./pipeline.md).

## Why is it so slow?

Transcription. Whisper on a CPU can take longer than the episode's own running time. Installing the CUDA build of PyTorch is the single biggest improvement available — see [Installation](./installation.md).

## Can I change the model?

Yes, though not without editing code. The Whisper and Ollama models are literals inside the stage scripts; [Configuration](./configuration.md) lists exactly which line. Remember to clear the relevant resume log, or nothing will be regenerated.

## Does this need an API key?

No. Everything either runs locally or reads public feeds. See [External Services](./api.md).

## I hold rights in the source material and want this taken down.

Open an issue or contact the repository owner. [`CONTENT_LICENSE.md`](../CONTENT_LICENSE.md) commits to honouring removal requests without argument or delay.
