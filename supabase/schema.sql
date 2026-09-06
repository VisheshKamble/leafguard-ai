-- ============================================================================
-- LeafGuard — Supabase schema
-- ============================================================================
-- Run this in the Supabase SQL editor (or via `supabase db push` if you keep
-- it as a migration). Safe to re-run: every statement is guarded.
--
-- Tables:
--   profiles       one row per authenticated user (auto-created on signup)
--   scans          cloud copy of on-device scan history, for signed-in users
--   chat_messages  AI-assistant conversation log (context + analytics)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- profiles
-- ----------------------------------------------------------------------------
create table if not exists public.profiles (
  id               uuid primary key references auth.users (id) on delete cascade,
  email            text,
  name             text,
  location         text,                 -- free-text "village/city, state"
  language_code    text not null default 'en',
  preferred_crops  text[] not null default '{}',
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

comment on table public.profiles is
  'One row per signed-in user. Populated automatically by handle_new_user() on signup.';

alter table public.profiles enable row level security;

drop policy if exists "profiles: select own" on public.profiles;
create policy "profiles: select own" on public.profiles
  for select using (auth.uid() = id);

drop policy if exists "profiles: update own" on public.profiles;
create policy "profiles: update own" on public.profiles
  for update using (auth.uid() = id);

drop policy if exists "profiles: insert own" on public.profiles;
create policy "profiles: insert own" on public.profiles
  for insert with check (auth.uid() = id);

-- Keep updated_at current on every change.
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists set_profiles_updated_at on public.profiles;
create trigger set_profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- Auto-create a profile row the moment someone signs up, seeded from
-- whatever metadata the client sent at signUp() time (see signup_screen.dart
-- / auth_provider.dart if you pass name, location, language there).
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, name, location, language_code)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data ->> 'name',
    new.raw_user_meta_data ->> 'location',
    coalesce(new.raw_user_meta_data ->> 'language_code', 'en')
  )
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer set search_path = public;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ----------------------------------------------------------------------------
-- scans
-- ----------------------------------------------------------------------------
-- Primary key is text, not uuid, because the Flutter app already generates
-- its own ids on-device (see ScanProvider) so offline scans can sync later
-- without an id collision or a second round-trip to mint one.
create table if not exists public.scans (
  id                 text primary key,
  user_id            uuid not null references auth.users (id) on delete cascade,
  class_name         text not null,        -- raw model label, e.g. Tomato___Late_blight
  crop_name          text,
  disease_name       text,
  is_healthy         boolean not null default false,
  confidence         numeric(5, 4) not null check (confidence >= 0 and confidence <= 1),
  severity           text not null check (severity in ('healthy', 'mild', 'severe')),
  image_path         text,                 -- storage path/URL if you upload the photo
  created_at         timestamptz not null default now()
);

comment on table public.scans is
  'Cloud copy of a farmer''s scan history. The app works fully offline via Hive; this is only used when the user is signed in and wants cross-device sync.';

create index if not exists scans_user_id_created_at_idx
  on public.scans (user_id, created_at desc);

alter table public.scans enable row level security;

drop policy if exists "scans: full access to own rows" on public.scans;
create policy "scans: full access to own rows" on public.scans
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ----------------------------------------------------------------------------
-- chat_messages
-- ----------------------------------------------------------------------------
create table if not exists public.chat_messages (
  id           text primary key,
  user_id      uuid not null references auth.users (id) on delete cascade,
  scan_id      text references public.scans (id) on delete set null,
  role         text not null check (role in ('user', 'assistant')),
  content      text not null,
  language_code text not null default 'en',
  created_at   timestamptz not null default now()
);

comment on table public.chat_messages is
  'AI-assistant conversation log. scan_id is set when the conversation started from a specific diagnosis (see ChatProvider.seedWithScanResult).';

create index if not exists chat_messages_user_id_created_at_idx
  on public.chat_messages (user_id, created_at desc);

create index if not exists chat_messages_scan_id_idx
  on public.chat_messages (scan_id);

alter table public.chat_messages enable row level security;

drop policy if exists "chat_messages: full access to own rows" on public.chat_messages;
create policy "chat_messages: full access to own rows" on public.chat_messages
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ============================================================================
-- Notes
-- ============================================================================
-- 1. The Flutter app currently calls .signInAnonymously()-free "continue
--    without account" flow for scanning -- these tables are only written to
--    once a user actually signs up/in. That's fine; on-device Hive storage
--    is the source of truth either way.
-- 2. If you want anonymous users to reach the AI chatbot too (no account),
--    enable anonymous sign-ins in Authentication > Providers, and deploy the
--    ai-chat edge function with --no-verify-jwt (see supabase/functions/ai-chat).
-- 3. To let signed-in users read this from more than one device, sync
--    scans/chat_messages after ScanProvider.analyze() succeeds and
--    ChatProvider.sendMessage() completes -- neither does so today by
--    default, both are safe additive hooks.
