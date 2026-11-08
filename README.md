# YouTube X

A Flutter starter app for Android and Windows that uses the official YouTube Data API v3 for public video discovery and opens videos on YouTube's official watch page.

## Features
- Search public YouTube videos
- Load popular videos
- Responsive dark UI for phone and desktop
- Opens videos with YouTube's official player in the YouTube app/browser
- GitHub Actions builds an Android APK and a Windows release ZIP

## Requirements
- Flutter stable (Dart 3.3+)
- A Google Cloud project with **YouTube Data API v3** enabled
- An API key for public-data requests

## Configure an API key
1. Open https://console.cloud.google.com/
2. Create/select a project and enable **YouTube Data API v3**.
3. Create an API key and restrict it to YouTube Data API v3 where possible.
4. Do not commit your key into source code.

For local testing:
```bash
flutter pub get
flutter run --dart-define=YOUTUBE_API_KEY=YOUR_API_KEY
```

For Android:
```bash
flutter build apk --release --dart-define=YOUTUBE_API_KEY=YOUR_API_KEY
```

For Windows (run on Windows):
```bash
flutter build windows --release --dart-define=YOUTUBE_API_KEY=YOUR_API_KEY
```
The Windows build output is in `build/windows/x64/runner/Release/`. Keep the entire Release folder together; the EXE needs its Flutter DLLs and data folder.

## GitHub Actions builds
Add a repository secret named `YOUTUBE_API_KEY` in **Settings → Secrets and variables → Actions**. The workflow uses it at build time. If no secret is configured, the workflow still builds, but API requests show a missing-key message.

Push to `main` or manually run **Actions → Build Android + Windows**. Download:
- `YouTube-X-Android-APK` for the APK
- `YouTube-X-Windows-x64` for the Windows app folder ZIP

## API and account limitations
This starter uses the official YouTube Data API v3 for public search/popular video metadata. It does not connect to private YouTube servers or bypass YouTube restrictions. Video playback is handed to YouTube's official website/app using a normal watch URL.

An API key does not sign a user into their Google/YouTube account. OAuth 2.0 consent and platform-specific client configuration are required for private account data or actions such as managing subscriptions. Those account features are not implemented in this initial build.

## Notes
- API quota limits and Google's API policies apply.
- Public API keys embedded in client apps can be extracted. Restrict the key and consider a small backend proxy for a production release.
- This project is an independent client and is not affiliated with YouTube or Google.
