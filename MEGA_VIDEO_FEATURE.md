# Mega Video Download Feature

## Overview
QNX app now supports video hosting from Mega.nz with automatic download and caching functionality.

## Features

### 1. Automatic Download
- When a Mega URL is detected, the app automatically downloads the video
- Shows progress bar with percentage during download
- Videos are cached locally for offline playback

### 2. Offline Playback
- Downloaded videos play instantly without re-downloading
- Stored in app's documents directory
- Survives app restarts

### 3. Storage Management
- Delete button (trash icon) appears on top bar when video is paused
- Confirmation dialog before deletion
- Can re-download anytime from Mega

## Usage

### Adding Mega Videos to materi.json
Replace YouTube URLs with Mega URLs:

```json
{
  "id": 1,
  "judul": {
    "en": "The Seafarer from India",
    "id": "Pelaut dari India"
  },
  "video": "https://mega.nz/file/HlREQRCJ#6XaQCAv1zvIvUHoqI3yBTEgPWk2iD-KX99uYm72Vaxg"
}
```

### Mega URL Format
```
https://mega.nz/file/{FILE_ID}#{DECRYPTION_KEY}
```

Example:
- FILE_ID: `HlREQRCJ`
- KEY: `6XaQCAv1zvIvUHoqI3yBTEgPWk2iD-KX99uYm72Vaxg`

## Implementation Details

### Dependencies
- `dio: ^5.4.0` - HTTP client for downloading
- `path_provider: ^2.1.2` - Access to app documents directory
- `permission_handler: ^11.3.0` - Storage permissions (Android)

### Files
- `lib/utils/mega_downloader.dart` - Core download logic
- `lib/pages/video_page.dart` - Updated to handle Mega videos

### Storage Location
- Android: `/data/data/com.example.qnx/app_flutter/videos/`
- Downloaded files named as: `{FILE_ID}.mp4`

## Permissions
Added to AndroidManifest.xml:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
```

## Advantages over YouTube
1. **Offline First** - Videos downloaded once, play forever
2. **No Ads** - Clean playback experience
3. **No Internet Required** - After initial download
4. **No Rate Limiting** - YouTube may throttle embeds
5. **Privacy** - No tracking from YouTube

## User Experience

### First Time Playing
1. User taps on material with Mega video
2. Download progress shows (e.g., "Downloading... 45.3%")
3. Video starts playing automatically when ready
4. Exercise button appears when paused

### Subsequent Plays
1. Video plays instantly from cache
2. No download indicator
3. Delete button available in top bar (when paused)

### Deleting Cache
1. Pause the video
2. Tap trash icon in top right
3. Confirm deletion
4. Returns to previous screen
5. Next play will re-download

## Testing
Test Mega URL:
```
https://mega.nz/file/HlREQRCJ#6XaQCAv1zvIvUHoqI3yBTEgPWk2iD-KX99uYm72Vaxg
```

Replace video URL in `assets/materi.json` ID 1 with above URL and test.

## Notes
- Videos should be in MP4 format for best compatibility
- Keep videos under 50MB for reasonable download times
- Mega free tier has bandwidth limits (check Mega.nz docs)
- Consider compressing videos before uploading to Mega
