"""
This script uses yt-dlp to download videos, by year, from the LCRC
YouTube Channel sermon playlist.
"""

import yt_dlp


def download_playlist(channel_url):
    """
    Downloads all videos from a YouTube playlist.
    """
    ydl_opts = {
        "format": "bestaudio",
        "ignoreerrors": True,
        "noplaylist": False,
        "download_archive": "downloaded.log",
        "outtmpl": "%(upload_date>%Y)s/%(title)s.%(ext)s",
        "postprocessors": [
            {
                "key": "FFmpegExtractAudio",
                "preferredcodec": "mp3",
                "preferredquality": "0",
            }
        ],
        "keepvideo": False,
        "remote_components": "ejs:github",
        'concurrent-fragments': True,
        'no-mtime': True
    }
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        ydl.download([channel_url])


if __name__ == "__main__":
    channel = "https://www.youtube.com/@LadnerChristianReformedChurch/streams"
    download_playlist(channel)
    print("Downloaded all videos from the Ladner Christian Reformed Church YouTube channel.")
