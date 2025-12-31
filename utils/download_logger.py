"""Script to extract video IDs from a YouTube playlist using yt-dlp
and write them to a corresponding log file."""

import yt_dlp

def get_playlist_video_ids(url):
    """Given a YouTube playlist URL, return 
    a list of video IDs in that playlist."""
    ydl_opts = {
        "quiet": True,
        "skip_download": True,
        "extract_flat": True,  # Don't resolve each video fully
    }

    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        info = ydl.extract_info(url, download=False)

    video_ids = []

    # Playlist entries contain "id" field when extract_flat=True
    for entry in info.get("entries", []):
        if entry and entry.get("id"):
            video_ids.append(entry["id"])

    return video_ids


if __name__ == "__main__":
    channel = "https://www.youtube.com/@LadnerChristianReformedChurch/streams"
    ids = get_playlist_video_ids(channel)

    # Write video IDs to 'downloaded.log'
    log_file = "../downloaded.log"
    with open(log_file, "w", encoding="utf-8") as f:
        for vid in ids:
            f.write(f"youtube {vid}\n")
            print("Wrote video ID:", vid)
