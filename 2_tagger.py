import os
import sys
import json
import re
from datetime import datetime
from urllib.error import HTTPError, URLError
from urllib.parse import parse_qs, urlencode, urlparse
from urllib.request import urlopen
from constants import YOUTUBE_API_KEY
from mutagen.easyid3 import EasyID3
from mutagen.id3 import ID3, TDRC, TRCK

# Log file name
LOG_FILENAME = "tagged.log"

PODCAST_NAME = "Ladner CRC"
YOUTUBE_API_BASE = "https://www.googleapis.com/youtube/v3/playlistItems"
YOUTUBE_CHANNELS_API_BASE = "https://www.googleapis.com/youtube/v3/channels"

def normalize(text):
    """Normalize strings for reliable matching."""
    text = text.lower()
    text = re.sub(r"\.mp3$", "", text) # remove .mp3 extension
    text = re.sub(r"[^\w\s]", "", text)  # remove punctuation
    text = re.sub(r"\s+", " ", text).strip() # collapse whitespace
    return text

def extract_channel_reference(channel_url):
    """Extract channel reference type and value from a YouTube channel URL."""
    parsed = urlparse(channel_url)
    path_parts = [part for part in parsed.path.split("/") if part]

    if not path_parts:
        raise ValueError("Channel URL is missing a path.")

    # Supported URL shapes:
    # /channel/UC...
    # /@handle
    # /user/<username>
    first = path_parts[0]
    if first == "channel" and len(path_parts) >= 2:
        return "id", path_parts[1]
    if first.startswith("@"):
        return "forHandle", first
    if first == "user" and len(path_parts) >= 2:
        return "forUsername", path_parts[1]

    raise ValueError(
        "Unsupported YouTube channel URL. Use /channel/<id>, /@handle, or /user/<name>."
    )

def parse_youtube_date(value):
    """Parse YouTube RFC3339 datetime into a sortable datetime."""
    # Catch cases where the date might be in an unexpected format
    try:
        return datetime.strptime(value[:10], "%Y-%m-%d")
    except ValueError as exc:
        raise RuntimeError(f"Unexpected date format from YouTube API: {value}") from exc

def youtube_api_get(base_url, params):
    """Perform a YouTube Data API GET request and return parsed JSON."""
    request_url = f"{base_url}?{urlencode(params)}"
    # Make the API request with error handling
    try:
        with urlopen(request_url, timeout=20) as response:
            payload = response.read().decode("utf-8")
    # Handle HTTP and URL errors
    except HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"YouTube API error {exc.code}: {body}") from exc
    # Handle network errors
    except URLError as exc:
        raise RuntimeError(f"Could not reach YouTube API: {exc.reason}") from exc

    # Parse the JSON response with error handling for invalid JSON
    try:
        data = json.loads(payload)
    except json.JSONDecodeError as exc:
        raise RuntimeError("YouTube API returned invalid JSON.") from exc

    # Validate that 'items' is present and is a list
    items = data.get("items")
    if not isinstance(items, list):
        raise RuntimeError("YouTube API response is missing an 'items' list.")

    return data

def fetch_playlist_page(playlist_id, api_key, page_token=None):
    """Fetch one page of playlist items from YouTube Data API."""
    # Build the API request URL
    params = {
        "part": "snippet,contentDetails",
        "playlistId": playlist_id,
        "maxResults": "50",
        "key": api_key,
        "fields": "nextPageToken,items(snippet(title,publishedAt),contentDetails(videoPublishedAt))",
    }
    if page_token:
        params["pageToken"] = page_token

    return youtube_api_get(YOUTUBE_API_BASE, params)

def resolve_uploads_playlist_id(channel_url, api_key):
    """Resolve a channel URL to its uploads playlist ID."""
    ref_type, ref_value = extract_channel_reference(channel_url)
    params = {
        "part": "contentDetails",
        "maxResults": "1",
        "key": api_key,
        "fields": "items(contentDetails(relatedPlaylists(uploads)))",
        ref_type: ref_value,
    }
    data = youtube_api_get(YOUTUBE_CHANNELS_API_BASE, params)

    items = data.get("items", [])
    if not items:
        raise RuntimeError(f"No channel found for URL: {channel_url}")

    uploads_playlist_id = (
        items[0]
        .get("contentDetails", {})
        .get("relatedPlaylists", {})
        .get("uploads")
    )
    if not uploads_playlist_id:
        raise RuntimeError("Could not resolve uploads playlist for channel.")

    return uploads_playlist_id

def fetch_playlist_data(channel_url):
    """Fetch all uploaded videos for a channel URL via YouTube Data API."""
    # Pass API key
    api_key = (YOUTUBE_API_KEY or "").strip()
    if not api_key:
        raise RuntimeError("Missing YOUTUBE_API_KEY in constants.py")

    playlist_id = resolve_uploads_playlist_id(channel_url, api_key)
    title_map = {} # normalized title → upload date
    page_token = None # pagination token for API requests

    # Loop through all pages of the playlist
    while True:
        data = fetch_playlist_page(playlist_id, api_key, page_token)
        for item in data["items"]:
            snippet = item.get("snippet", {})
            content_details = item.get("contentDetails", {})
            title = snippet.get("title")
            published_at = content_details.get("videoPublishedAt") or snippet.get("publishedAt")

            if title and published_at:
                title_map[normalize(title)] = parse_youtube_date(published_at)

        page_token = data.get("nextPageToken")
        if not page_token:
            break
    return title_map

def process_year_folder(folder_path, year, title_map):
    """Process all MP3 files in the given folder,
    matching them to playlist data and updating ID3 tags."""
    files_with_dates = []

    # Path to the log file
    log_path = os.path.join(folder_path, LOG_FILENAME)

    # Read already tagged files from log
    tagged_files = set()
    if os.path.exists(log_path):
        with open(log_path, "r", encoding="utf-8") as log_file:
            for line in log_file:
                tagged_files.add(line.strip())

    # Gather all MP3 files and corresponding upload dates
    for file in os.listdir(folder_path):
        if not file.lower().endswith(".mp3"):
            continue
        # Normalize filename for matching
        norm_name = normalize(file)
        # Check for matching title in playlist data
        if norm_name not in title_map:
            print(f"Skipping (no match): {file}")
            continue
        # Store full path and upload date for sorting
        full_path = os.path.join(folder_path, file)
        files_with_dates.append((full_path, title_map[norm_name]))

    # Sort by upload date
    files_with_dates.sort(key=lambda x: x[1])

    # Update ID3 tags in sorted order
    with open(log_path, "a", encoding="utf-8") as log_file:
        for idx, (filepath, date) in enumerate(files_with_dates, start=1):
            filename = os.path.basename(filepath)

            if filename in tagged_files:
                print(f"Skipping (already tagged): {filename}")
                continue

            try:
                audio = EasyID3(filepath)
                audio["artist"] = PODCAST_NAME
                audio["albumartist"] = PODCAST_NAME
                audio["album"] = year
                audio["tracknumber"] = str(idx)
                audio.save(filepath)
                id3 = ID3(filepath)

                # Album date = Jan 1 of year
                id3.delall("TDRC")
                id3.add(TDRC(encoding=3, text=f"{year}-01-01"))

                # Track number
                id3.delall("TRCK")
                id3.add(TRCK(encoding=3, text=str(idx)))
                id3.save(filepath)

                log_file.write(filename + "\n")
                log_file.flush()
                tagged_files.add(filename)

                print(f"Updated: {filename} → Track {idx}")
            except Exception as e:
                print(f"Error with {filepath}: {e}")

if __name__ == "__main__":
    if len(sys.argv) not in (2, 3):
        print("Usage: python 2_tagger.py <year>")
        sys.exit(1)
    else:
        year = sys.argv[1]
        channel_url = "https://www.youtube.com/@LadnerChristianReformedChurch"

        print("Fetching channel metadata via YouTube API...")
        title_map = fetch_playlist_data(channel_url)
        print(f"Processing year: {year}")
        process_year_folder(year, year, title_map)
