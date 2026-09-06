# LeafGuard

LeafGuard is a Flutter application for offline crop disease detection. It
allows a farmer to capture or select a leaf image, run an embedded TensorFlow
Lite model on the device, review the diagnosis, save scan history locally, and
optionally use Supabase for authentication, cloud synchronization, and an AI
plant-health assistant.

The application is designed around a local-first principle. Disease
classification does not require an internet connection. Cloud services are
additive capabilities and must not prevent a user from scanning or reviewing
locally stored results.

## Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Architecture](#architecture)
- [Machine Learning Model](#machine-learning-model)
- [Data and Storage](#data-and-storage)
- [Authentication](#authentication)
- [AI Assistant](#ai-assistant)
- [Supabase Database](#supabase-database)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the Application](#running-the-application)
- [Deployment](#deployment)
- [Project Structure](#project-structure)
- [Limitations and Operational Notes](#limitations-and-operational-notes)
- [System Design Documentation](#system-design-documentation)

## Project Overview

LeafGuard combines on-device machine learning with an optional cloud backend.
The device performs image classification locally, which provides low latency,
improves operation in areas with unreliable connectivity, and keeps the leaf
image away from the cloud inference path. Supabase provides managed
authentication and PostgreSQL services when the user chooses to use an
account. The AI assistant runs through a Supabase Edge Function so the Groq
API key is never shipped in the mobile application.

## Features

- Camera and gallery image input.
- On-device crop disease classification with TensorFlow Lite.
- Local scan history using Hive.
- Optional signed-in user accounts through Supabase Auth.
- Optional best-effort scan synchronization to Supabase PostgreSQL.
- AI plant-health assistant powered by a Groq-hosted model.
- Scan-aware chat context, including crop, disease, confidence, and severity.
- Language-aware AI responses and localized application navigation.
- Configurable farmer location and preferred crops for more relevant advice.
- Disease results, severity, confidence, history, treatment information, and
   settings screens.
- Guest usage for scanning without a Supabase account.

## Architecture

The system has four principal layers:

1. **Flutter presentation layer**: screens and reusable widgets provide the
    scan, result, history, chat, authentication, onboarding, and settings
    experiences.
2. **Provider state layer**: `AuthProvider`, `ScanProvider`,
    `HistoryProvider`, `ChatProvider`, and `LocaleProvider` coordinate UI state
    and service calls.
3. **Local services**: `TFLiteService` performs inference and
    `LocalStorageService` stores scan history in Hive.
4. **Optional cloud services**: `SupabaseService` handles authentication and
    best-effort scan synchronization, while `AIChatService` invokes the
    `ai-chat` Edge Function.

The normal scan flow is:

```text
Camera or gallery image
            |
            v
Image preprocessing and resize to 224 x 224
            |
            v
TensorFlow Lite inference on the device
            |
            v
Diagnosis, confidence, and severity
            |
            +--> Hive local scan history
            |
            +--> Optional Supabase scan synchronization
```

The AI flow is:

```text
Flutter chat screen
            |
            v
Supabase Edge Function: ai-chat
            |
            +--> Supabase server secret: GROQ_API_KEY
            |
            v
Groq OpenAI-compatible chat completions API
            |
            v
Response returned to Flutter
```

## Machine Learning Model

The application uses the following bundled model assets:

```text
assets/model/leafguard_v1_int8.tflite
assets/model/labels.txt
```

The model is a full-integer quantized TensorFlow Lite model. The runtime
implementation in `TFLiteService`:

1. Reads the selected image from the device.
2. Decodes the image using the Dart image package.
3. Resizes it to the configured model input size of 224 x 224 pixels.
4. Builds a uint8 RGB tensor with shape `[1, 224, 224, 3]`.
5. Runs the TensorFlow Lite interpreter locally.
6. Selects the highest scoring output class.
7. Converts the quantized output score from the 0-255 range to a confidence
    value between 0.0 and 1.0.

The output class names are read in order from `labels.txt`. The labels file
must match the class order used when the model was trained. The training
notebook is stored in `notebook/leafguardmodelnotebook.ipynb`; the generated
model and labels must be copied into `assets/model/` before running the app.

The model is an assistive classifier, not a replacement for an agronomist or
laboratory diagnosis. Results depend on image quality, lighting, leaf angle,
crop variety, disease stage, and whether the target condition is represented
in the training data.

## Data and Storage

### Local storage

Hive stores scan results in the `scan_history` box. It is the primary source
for the history displayed by the application. Local storage enables:

- Offline scanning.
- Offline history browsing.
- Fast result loading.
- Continued use when Supabase is unavailable or not configured.

### Cloud storage

Supabase PostgreSQL contains the optional cloud records for authenticated
users. The intended tables are:

- `profiles`: user profile and preferences.
- `scans`: cloud copies of locally generated scan records.
- `chat_messages`: conversation records for future or extended chat logging.

The current application performs best-effort scan synchronization through
`SupabaseService`. It does not make cloud availability a prerequisite for
local scanning. The current chat provider sends requests to the Edge Function
but does not automatically persist every chat turn to `chat_messages`.

## Authentication

Authentication is implemented with Supabase Auth and email/password flows.
`AuthProvider` delegates sign-up, sign-in, and sign-out operations to
`SupabaseService`, which calls the Supabase Flutter client.

Authentication is optional for the core scan flow. When the app is built
without valid Supabase runtime configuration, cloud features are disabled but
local scanning and local history remain available.

The checked-in database schema creates a profile automatically after a new
Supabase user is created. Row Level Security policies restrict profile,
scan, and chat records to the authenticated owner.

## AI Assistant

The AI assistant is implemented as a Supabase Edge Function:

```text
supabase/functions/ai-chat/index.ts
```

The function accepts a message and optional context including:

- Recent user and assistant turns.
- Selected language.
- Farmer location.
- Preferred crops.
- The latest scan's crop, disease, confidence, severity, and description.

The function uses Groq's OpenAI-compatible endpoint and defaults to:

```text
openai/gpt-oss-120b
```

The model name can be changed with the `AI_CHAT_MODEL` Supabase secret. The
Groq key is read only on the server through `Deno.env` and must never be
placed in Flutter code, a mobile `.env` file, or a Dart define.

The Edge Function returns JSON using UTF-8 and validates malformed request
bodies, missing messages, provider failures, and empty provider responses.

AI chat requires an authenticated Supabase user. The function also enforces a
32 KB request limit, bounds message and history sizes, and limits each user to
20 requests per minute. These controls protect the server-side Groq quota;
guest users can still scan locally but cannot use AI chat until they sign in.

## Supabase Database

The complete schema is in:

```text
supabase/schema.sql
```

It creates:

- `public.profiles` with an automatic user-creation trigger.
- `public.scans` with confidence and severity constraints.
- `public.chat_messages` with role and ownership constraints.
- Indexes for user history and scan-linked chat records.
- Row Level Security policies for user-owned records.
- An `updated_at` trigger for profiles.

Run the schema in the Supabase SQL Editor. If the project is managed with
Supabase migrations, use the equivalent migration workflow rather than
executing the schema repeatedly in production.

## Requirements

- Flutter SDK compatible with the Dart constraint in `pubspec.yaml`.
- Dart 3 or later.
- Android Studio and an Android SDK for Android builds, or Xcode for iOS
   builds.
- A Supabase project for authentication, cloud data, and AI chat.
- A Groq API key for the AI assistant.
- The trained TensorFlow Lite model and matching labels file.

## Installation

Install Flutter dependencies:

```powershell
flutter pub get
```

The repository includes native platform directories. If setting up from a
source export that does not contain them, generate the platform scaffolding
with:

```powershell
flutter create .
```

Verify that the model assets exist:

```text
assets/model/leafguard_v1_int8.tflite
assets/model/labels.txt
```

The Android and iOS projects must include camera and photo-library permission
descriptions. The existing platform projects should be checked before a
release build.

## Configuration

The Flutter app reads the public Supabase project URL and public anon key at
compile time using Dart defines:

```text
SUPABASE_URL
SUPABASE_ANON_KEY
```

These are client configuration values. They do not replace database security
policies and must not be confused with the private Groq key.

For local Edge Function development, create the ignored file:

```text
supabase/functions/.env
```

with server-side values:

```env
GROQ_API_KEY=gsk_your_key_here
AI_CHAT_MODEL=openai/gpt-oss-120b
```

Never commit this file. The repository includes a non-secret template at
`supabase/functions/.env.example`.

## Running the Application

Run without cloud features:

```powershell
flutter run
```

Run with Supabase configured:

```powershell
flutter run `
   --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co `
   --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY
```

Use the public anon key from Supabase Dashboard -> Settings -> API. Do not
use the Groq key in this command.

## Deployment

### Supabase setup

From the project root, authenticate and link the local repository:

```powershell
npx supabase login
npx supabase link --project-ref YOUR_PROJECT_REF
```

Apply the database schema in the Supabase SQL Editor, then configure the
server-side secrets:

```powershell
npx supabase secrets set GROQ_API_KEY=YOUR_GROQ_KEY
npx supabase secrets set AI_CHAT_MODEL=openai/gpt-oss-120b
```

Deploy the Edge Function:

```powershell
npx supabase functions deploy ai-chat
```

Do not use `--no-verify-jwt`. The repository's `supabase/config.toml` enables
platform JWT verification, and the function performs a second authenticated
user check before calling Groq. Verify the deployed setting with:

```powershell
npx supabase functions list --project-ref YOUR_PROJECT_REF
```

The `ai-chat` function should report `verify_jwt: true`. The Groq API key must
only exist in Supabase secrets or the ignored local function env file. The
Flutter `SUPABASE_ANON_KEY` is a public client key; never place a
`service_role` key or Groq key in the app or a Dart define.

### Flutter Android build

Build a release APK with the public Supabase configuration:

```powershell
flutter build apk --release `
   --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co `
   --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY
```

The APK is generated at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Production Android distribution also requires application signing and the
usual Play Store release configuration. Production iOS distribution requires
Apple signing, provisioning, and App Store configuration.

## Project Structure

```text
lib/
   app.dart                         Application initialization and providers
   main.dart                        Flutter entry point
   core/                            Constants, theme, and localization
   models/                          Domain models for scans and chat
   providers/                       Application state management
   screens/                         Auth, scan, results, chat, history, and settings UI
   services/                        TFLite, Hive, Supabase, camera, and AI services
   widgets/                         Reusable application widgets

assets/
   model/                           TensorFlow Lite model and class labels
   images/                          Optional static image assets

supabase/
   schema.sql                       PostgreSQL schema and RLS policies
   functions/ai-chat/index.ts       Groq-backed Edge Function

system design/
   leafguard-system-design.md       Mermaid architecture and deployment diagrams

notebook/
   leafguardmodelnotebook.ipynb     Model training notebook
```

## Limitations and Operational Notes

- The disease model provides an assistive prediction and should not be
   treated as a definitive professional diagnosis.
- Local Hive history and cloud Supabase history are separate stores. Cloud
   synchronization is currently best-effort rather than a full offline queue.
- The current chat provider does not automatically insert messages into the
   `chat_messages` table.
- User image uploads and Supabase Storage are not currently implemented.
- AI responses can be incomplete or incorrect. Treatment advice should be
   checked against local agricultural guidance and product labels.
- The Edge Function is deployed with JWT verification disabled for the guest
   flow. This should be reviewed before production use, including rate
   limiting, abuse controls, and authenticated sessions.
- Rotate a Groq key immediately if it is exposed in source code, terminal
   history, logs, screenshots, or chat messages.

## System Design Documentation

The complete architecture and deployment diagrams are maintained in:

[LeafGuard System Design](system%20design/leafguard-system-design.md)

The diagrams show the separation between on-device inference, local Hive
storage, optional Supabase services, the Edge Function, and the Groq API.

## License

See [LICENSE](LICENSE) for the project license.
