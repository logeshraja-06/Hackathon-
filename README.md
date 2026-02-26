# Smart Crop Demand Planner (MVP)

A minimal, hackathon-friendly Flutter mobile app for farmers. Features include a high-demand crop dashboard, smart recommendations, basic buyer matching, and a Tamil/English localization.

## Setup Instructions

1. Ensure you have Flutter installed (`flutter --version`).
2. Clone or place this project folder.
3. Run `flutter pub get` to fetch dependencies.
4. Run the app in development: `flutter run`

## Building unsigned APK

To build a release APK for Android testing:
```bash
flutter build apk --release
```
The APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

## Signing the APK for Production (Android)

1. Generate Keystore:
```bash
keytool -genkey -v -keystore smartcrop-key.keystore -alias smartcrop -keyalg RSA -keysize 2048 -validity 10000
```
2. Build unsigned app bundle or APK:
```bash
flutter build apk --release
```
3. Sign the APK:
```bash
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore smartcrop-key.keystore build/app/outputs/flutter-apk/app-release.apk smartcrop
```
4. Zipalign the APK:
```bash
zipalign -v 4 build/app/outputs/flutter-apk/app-release.apk smartcrop-aligned.apk
```

## CI/CD and Replit Notes

If you are using Replit, note that compiling an Android APK natively might fail due to missing Android build tools.
Instead, simply push this repository to GitHub and GitHub Actions will automatically build the APK for you via the `.github/workflows/build-apk.yml` workflow. Go to the "Actions" tab in your repository to download the `smartcrop-apk` artifact.

**Application ID:** `com.antigarvity.smartcrop`
