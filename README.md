<!-- Logo -->
<h1 align="center">
  LCRC Sermon Transcripts
</h1>

<!-- Copy -->
<h4 align="center">Transcripts and summaries generated from the Ladner CRC sermons through OpenAI Whisper, Llama 3.1, and LanguageTool.</h4>

<!-- Badges -->
<div align="center">
  <!-- Issues -->
  <img alt="GitHub Issues" src="https://img.shields.io/github/issues/willtheorangeguy/LCRC-Sermon-Transcripts">
  <!-- Pull Requests -->
  <img alt="GitHub Pull Requests" src="https://img.shields.io/github/issues-pr/willtheorangeguy/LCRC-Sermon-Transcripts">
  <!-- Discord -->
  <img alt="Discord Server ID" src="https://img.shields.io/discord/1382526731528962088">
  <!-- Language Count -->
  <img alt="GitHub Languages" src="https://img.shields.io/github/languages/count/willtheorangeguy/LCRC-Sermon-Transcripts">
</div>

<!-- Navigation -->
<p align="center">
  <a href="#key-features">Key Features</a> •
  <a href="#how-to-use">How To Use</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#changelog">Changelog</a> •
  <a href="#credits">Credits & Contributors</a>
</p>

## Key Features

- Ability to download all pre-created transcripts.
- Pull audio of all LCRC sermons.
- Create transcripts for every episode using OpenAI's Whisper.
- Generate a summary from the transcript using Ollama and Llama.
- Correct spelling and grammatical errors using LanguageTool.

## How To Use

**To clone and run your own copy of this website**, you'll need [Git](https://git-scm.com/downloads), [Ollama](https://ollama.com/) and a bunch of Python libraries installed on your computer. If you would rather not use Git, you can just download the code from GitHub [above](https://github.com/willtheorangeguy/LCRC-Sermon-Transcripts/archive/refs/heads/main.zip). From your command line:

```bash
# Clone this repository
$ git clone https://github.com/willtheorangeguy/LCRC-Sermon-Transcripts.git

# Go into the repository
$ cd LCRC-Sermon-Transcripts

# Install Dependencies + Run
$ pip install -r requirements.txt
$ pip install git+https://github.com/openai/whisper.git
$ pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
$ python main.py <year>
```

If support is required, please open a **[GitHub Discussion](https://github.com/willtheorangeguy/LCRC-Sermon-Transcripts/discussions/new)** or join our **[Discord](https://discord.gg/mgbda4fesN)**.

## Contributing

Please contribute using [GitHub Flow](https://guides.github.com/introduction/flow). Create a branch, add commits, and [open a pull request](https://github.com/willtheorangeguy/LCRC-Sermon-Transcripts/compare).

Please read [`CONTRIBUTING`](CONTRIBUTING.md) for details on our [`CODE OF CONDUCT`](CODE_OF_CONDUCT.md), and the process for submitting pull requests to us.

## Changelog

See the [`CHANGELOG`](CHANGELOG.md) file for details.

## Credits

This software uses the following open source packages, projects, services or websites:

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

## Contributors

- [@willtheorangeguy](https://github.com/willtheorangeguy) - Sponsor on [PayPal](https://paypal.me/wvdg44?country.x=CA&locale.x=en_US)

## You may also like...

- [LCRC Sermon Transcripts](https://github.com/willtheorangeguy/LCRC-Sermon-Transcripts)
- [WAN Transcripts](https://github.com/willtheorangeguy/WAN-Transcripts)

## License

The code in this repository is licensed under the [MIT License](https://mit-license.org/) - see the [`LICENSE`](LICENSE.md) file for details. The transcription of sermons contains spoken words which are copyright and the individual perspective of their respective speaker. This repository is in no way affiliated with OpenAI, YouTube, Google, or Ladner Christian Reformed Church.
