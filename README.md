<!-- Logo -->
<h1 align="center">LCRC Sermon Transcripts</h1>

<!-- Copy -->
<h4 align="center">Transcripts and summaries generated from the Ladner CRC sermons through OpenAI Whisper, Llama 3.1, and LanguageTool.</h4>

<!-- Badges -->
<div align="center">
  <img alt="GitHub Issues" src="https://img.shields.io/github/issues/willtheorangeguy/LCRC-Sermon-Transcripts">
  <img alt="GitHub Pull Requests" src="https://img.shields.io/github/issues-pr/willtheorangeguy/LCRC-Sermon-Transcripts">
  <img alt="License" src="https://img.shields.io/github/license/willtheorangeguy/LCRC-Sermon-Transcripts">
</div>

<!-- Navigation -->
<p align="center">
  <a href="#key-features">Key Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#support">Support</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#credits">Credits</a> •
  <a href="#license">License</a>
</p>

## Key Features

- Ability to download all pre-created transcripts.
- Pull audio of all LCRC sermons.
- Create transcripts for every episode using OpenAI's Whisper.
- Generate a summary from the transcript using Ollama and Llama.
- Correct spelling and grammatical errors using LanguageTool.

## Installation

Requires [Python](https://www.python.org/downloads/), [Ollama](https://ollama.com/), and [ffmpeg](https://ffmpeg.org/).

```bash
git clone https://github.com/willtheorangeguy/LCRC-Sermon-Transcripts.git
cd LCRC-Sermon-Transcripts
pip install -r requirements.txt
```

Full prerequisites, including GPU-accelerated Whisper, are in [`docs/usage.md`](docs/usage.md).

## Usage

```bash
python main.py <show> <year>
```

That runs the whole pipeline end to end. It covers `2020`, `2021`, `2022`, `2023`, and 2 more.

## Documentation

Full documentation lives in [`docs/`](docs/README.md):
[Quickstart](docs/quickstart.md) · [Installation](docs/installation.md) · [Configuration](docs/configuration.md) · [Architecture](docs/architecture.md) · [Pipeline](docs/pipeline.md) · [FAQ](docs/faq.md) · [Troubleshooting](docs/troubleshooting.md)

## Support

Open a [GitHub Discussion](https://github.com/willtheorangeguy/LCRC-Sermon-Transcripts/discussions/new) or file an [issue](https://github.com/willtheorangeguy/LCRC-Sermon-Transcripts/issues/new/choose).

## Contributing

Contributions welcome. See the org-wide [Contributing Guide](https://github.com/willtheorangeguy/.github/blob/main/CONTRIBUTING.md) and [Code of Conduct](https://github.com/willtheorangeguy/.github/blob/main/CODE_OF_CONDUCT.md).

## Credits

<!-- Credits Table -->
<table>
  <tr>
    <th align="center"><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Python-logo-notext.svg/182px-Python-logo-notext.svg.png" width="150" height="150" alt="Python"/></th>
    <th align="center"><img src="https://static.vecteezy.com/system/resources/previews/022/227/364/large_2x/openai-chatgpt-logo-icon-free-png.png" width="150" height="150" alt="OpenAI Whisper"/></th>
    <th align="center"><img src="https://registry.npmmirror.com/@lobehub/icons-static-png/1.49.0/files/dark/ollama.png" width="150" height="150" alt="Ollama"/></th>
    <th align="center"><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/LanguageTool_Logo.svg/140px-LanguageTool_Logo.svg.png" width="150" height="150" alt="LanguageTool"/></th>
  </tr>
  <tr>
    <td align="center">Python</td>
    <td align="center">OpenAI Whisper</td>
    <td align="center">Ollama</td>
    <td align="center">LanguageTool</td>
  </tr>
  <tr>
    <td align="center"><a href="https://www.python.org/">Web</a> - <a href="https://psfmember.org/civicrm/contribute/transact/?reset=1&id=2">Donate</a></td>
    <td align="center"><a href="https://github.com/openai/whisper">GitHub</a></td>
    <td align="center"><a href="https://github.com/ollama/ollama">GitHub</a></td>
    <td align="center"><a href="https://github.com/jxmorris12/language_tool_python">GitHub</a></td>
  </tr>
</table>

## License

The pipeline code is MIT — see [`LICENSE.md`](LICENSE.md).

**The transcripts are not.** They are machine-generated from recordings of the Ladner CRC sermons, and the words belong to their speakers and rights holders. See [`CONTENT_LICENSE.md`](CONTENT_LICENSE.md) before reusing any of it.
