# LeafGuard — Flutter App

Offline, on-device crop disease detection. See the root project README for the
full problem statement, model training pipeline, and architecture.

## Setup

This zip contains the Dart source (`lib/`), `pubspec.yaml`, and `assets/` --
it does **not** include the generated native `android/`/`ios/` platform
folders, since those are large, machine-generated boilerplate that Flutter
creates for you rather than something to hand-author or download as static
files.

1. Generate the native scaffolding in this folder:
   ```bash
   flutter create .
   ```
   This fills in `android/`, `ios/`, and other platform folders around the
   `lib/` and `pubspec.yaml` already here, without overwriting them.
2. Install dependencies:
   ```bash
   flutter pub get
   ```

## Camera and gallery permissions

After running `flutter create .`, add camera permission entries (required by
the `camera` package). If this zip already includes `android/` and `ios/`
(most exports do), these are already in place.

- **Android** (`android/app/src/main/AndroidManifest.xml`): add
  `<uses-permission android:name="android.permission.CAMERA" />`
- **iOS** (`ios/Runner/Info.plist`): add an `NSCameraUsageDescription` key
  with a short explanation string (e.g. "LeafGuard needs the camera to scan
  leaves."), and an `NSPhotoLibraryUsageDescription` key for the gallery
  picker (e.g. "LeafGuard needs photo library access so you can diagnose a
  leaf from an existing photo.")

Scanning also accepts a photo from the gallery, not just the live camera --
`image_picker` handles its own Android runtime permission prompt, so no
extra Android manifest entry is needed for that one.

## Language

The scan flow, navigation, and other app chrome are available in English,
Hindi, Marathi, Telugu, Tamil, Bengali, Gujarati, Kannada, and Punjabi --
switch from the globe icon on the home screen. The disease guide's
descriptions and treatment steps stay in English: that content is
agronomic/scientific, and translating it without an agronomist reviewing
each entry risked giving a farmer subtly wrong advice, which is worse than
an English paragraph in an otherwise-local interface. `lib/core/localization/`
is where both the language list and the string tables live if you want to
extend either one.

## Add the trained model

Download `leafguard_v1_int8.tflite` and `labels.txt` from your Kaggle
notebook's Output panel (see `notebooks/leafguard_training.ipynb`), then copy
both files into:

```
assets/model/leafguard_v1_int8.tflite
assets/model/labels.txt
```

The app will not start without these two files present — `TFLiteService`
loads them at launch.

## Supabase

Set your project URL and anon key in `lib/core/constants/app_constants.dart`
(`supabaseUrl`, `supabaseAnonKey`). The app works fully offline without this
configured correctly for local scanning — Supabase is only used for optional
auth and cloud sync of scan history.

## Run

```bash
flutter run
```
