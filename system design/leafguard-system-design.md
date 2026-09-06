# LeafGuard System Design

## Architecture Overview

```mermaid
flowchart TB
    farmer[Farmer]

    subgraph client[Flutter Mobile App]
        ui[Flutter UI\nScreens and Widgets]
        providers[Provider State Layer\nAuth, Scan, Chat, History]
        capture[Camera or Gallery\nImage Capture]
        model[On-device TFLite Model\nleafguard_v1_int8.tflite]
        local[Hive Local Storage\nScan History]
        constants[Public Runtime Config\nSupabase URL + anon key]
    end

    subgraph supabase[Supabase Project]
        auth[Supabase Auth]
        edge[Edge Function: ai-chat]
        database[(Postgres Database)]
        rls[Row Level Security]
        secrets[Supabase Secrets\nGROQ_API_KEY\nAI_CHAT_MODEL]
    end

    groq[Groq API\nopenai/gpt-oss-120b]

    farmer --> ui
    ui --> providers
    providers --> capture
    capture --> model
    model --> providers
    providers --> local
    local --> providers
    constants --> providers

    providers -. optional sign-in .-> auth
    providers -. best-effort scan sync .-> database
    database --> rls
    rls --> auth

    providers -. chat request .-> edge
    edge --> secrets
    edge --> groq
    groq --> edge
    edge -. reply .-> providers

    classDef local fill:#e8f5e9,stroke:#2e7d32,color:#1b5e20
    classDef cloud fill:#e3f2fd,stroke:#1565c0,color:#0d47a1
    classDef secret fill:#fff3e0,stroke:#ef6c00,color:#e65100
    class model,local,capture local
    class auth,edge,database,rls cloud
    class secrets secret
```

## Main Runtime Flows

### Offline scan

1. The farmer captures a photo or selects one from the gallery.
2. `TFLiteService` resizes the image and runs the bundled model locally.
3. The prediction and confidence are shown immediately by the Flutter UI.
4. `LocalStorageService` saves the result in Hive, even without internet.
5. If Supabase is configured and the user is signed in, `SupabaseService` attempts a best-effort cloud sync.

### AI assistant

1. The Flutter app sends the message, recent chat history, language, and optional scan context to the `ai-chat` Edge Function.
2. The Edge Function reads `GROQ_API_KEY` and `AI_CHAT_MODEL` from Supabase environment secrets.
3. The function sends the request to Groq's OpenAI-compatible API.
4. Groq's response returns through the Edge Function to the Flutter app.
5. The Groq key is never included in the Flutter application or returned to the client.

### Authentication and data protection

- Supabase Auth manages signed-in users.
- `profiles`, `scans`, and `chat_messages` are stored in Postgres.
- Row Level Security limits records to the owning authenticated user.
- Local Hive storage remains the primary source for the app's scan history.
- The AI function can be deployed with JWT verification disabled for the demo's guest flow, or used with anonymous/authenticated Supabase sessions.

## Deployment Boundary

```mermaid
flowchart LR
    source[Project Source]
    build[Flutter Build]
    app[User Device]
    function[Supabase Edge Function]
    secret[Supabase Secret Store]
    provider[Groq API]

    source --> build --> app
    source --> function
    secret --> function
    function --> provider

    key[GROQ_API_KEY] -. never bundled .-> app
```

The Supabase anon key and project URL are public client configuration. The Groq API key is a server secret and must only be configured with Supabase secrets or a local server-side env file for development.
