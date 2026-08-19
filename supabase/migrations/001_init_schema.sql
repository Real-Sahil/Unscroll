-- Enable RLS
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO postgres, anon, authenticated, service_role;

-- Create custom types
CREATE TYPE user_role AS ENUM ('adult', 'parent', 'child', 'therapist');
CREATE TYPE platform_type AS ENUM ('ios', 'android', 'chrome', 'firefox', 'safari');
CREATE TYPE policy_mode AS ENUM ('personal', 'family');
CREATE TYPE friction_level_type AS ENUM ('low', 'medium', 'hard');
CREATE TYPE relapse_event_type AS ENUM ('protection_disabled', 'panic_button', 'friction_bypassed');

-- Profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  role user_role NOT NULL DEFAULT 'adult',
  risk_windows_json JSONB,
  goals_text TEXT,
  accountability_enabled BOOLEAN DEFAULT FALSE,
  accountability_partner_email TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Devices table
CREATE TABLE IF NOT EXISTS devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  platform platform_type NOT NULL,
  app_version TEXT,
  last_seen_at TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(profile_id, platform)
);

-- Policies table
CREATE TABLE IF NOT EXISTS policies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  mode policy_mode NOT NULL,
  schedule_json JSONB,
  daily_cap_min INT,
  hard_block_enabled BOOLEAN DEFAULT TRUE,
  cooldown_after_disable_hours INT DEFAULT 24,
  panic_cooldown_hours INT DEFAULT 12,
  default_hard_block BOOLEAN DEFAULT TRUE,
  friction_level friction_level_type DEFAULT 'hard',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Policy rules table
CREATE TABLE IF NOT EXISTS policy_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  policy_id UUID NOT NULL REFERENCES policies(id) ON DELETE CASCADE,
  app TEXT NOT NULL CHECK (app IN ('instagram', 'youtube', 'tiktok', 'all')),
  block_shorts BOOLEAN DEFAULT TRUE,
  block_reels BOOLEAN DEFAULT TRUE,
  block_stories BOOLEAN DEFAULT FALSE,
  disable_autoplay BOOLEAN DEFAULT TRUE,
  approved_channels_only BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Approved channels table
CREATE TABLE IF NOT EXISTS approved_channels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  policy_id UUID NOT NULL REFERENCES policies(id) ON DELETE CASCADE,
  platform TEXT NOT NULL CHECK (platform IN ('instagram', 'youtube', 'tiktok')),
  channel_id TEXT NOT NULL,
  label TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Family members table
CREATE TABLE IF NOT EXISTS family_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  child_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(parent_id, child_id)
);

-- Family invites table
CREATE TABLE IF NOT EXISTS family_invites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  child_email TEXT NOT NULL,
  invite_code TEXT UNIQUE NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL DEFAULT now() + INTERVAL '7 days',
  accepted BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Usage events table
CREATE TABLE IF NOT EXISTS usage_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  device_id UUID REFERENCES devices(id) ON DELETE SET NULL,
  event_type TEXT NOT NULL,
  ts TIMESTAMPTZ NOT NULL DEFAULT now(),
  meta_json JSONB
);

-- Relapse events table
CREATE TABLE IF NOT EXISTS relapse_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  event_type relapse_event_type NOT NULL,
  ts TIMESTAMPTZ NOT NULL DEFAULT now(),
  meta_json JSONB
);

-- Accountability links table
CREATE TABLE IF NOT EXISTS accountability_links (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  partner_email TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(owner_profile_id, partner_email)
);

-- Accountability summaries table
CREATE TABLE IF NOT EXISTS accountability_summaries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  week_start DATE NOT NULL,
  relapse_count INT DEFAULT 0,
  total_focus_off_min INT DEFAULT 0,
  panic_button_count INT DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(profile_id, week_start)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
CREATE INDEX IF NOT EXISTS idx_devices_profile_id ON devices(profile_id);
CREATE INDEX IF NOT EXISTS idx_policies_owner ON policies(owner_profile_id);
CREATE INDEX IF NOT EXISTS idx_policy_rules_policy_id ON policy_rules(policy_id);
CREATE INDEX IF NOT EXISTS idx_family_members_parent_id ON family_members(parent_id);
CREATE INDEX IF NOT EXISTS idx_family_members_child_id ON family_members(child_id);
CREATE INDEX IF NOT EXISTS idx_usage_events_profile_id ON usage_events(profile_id);
CREATE INDEX IF NOT EXISTS idx_usage_events_ts ON usage_events(ts DESC);
CREATE INDEX IF NOT EXISTS idx_relapse_events_profile_id ON relapse_events(profile_id);
CREATE INDEX IF NOT EXISTS idx_relapse_events_ts ON relapse_events(ts DESC);
CREATE INDEX IF NOT EXISTS idx_accountability_links_owner ON accountability_links(owner_profile_id);
CREATE INDEX IF NOT EXISTS idx_accountability_summaries_profile_week ON accountability_summaries(profile_id, week_start DESC);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE policy_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE approved_channels ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_invites ENABLE ROW LEVEL SECURITY;
ALTER TABLE usage_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE relapse_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE accountability_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE accountability_summaries ENABLE ROW LEVEL SECURITY;

-- RLS Policies for profiles
CREATE POLICY "Users can read their own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- RLS Policies for devices
CREATE POLICY "Users can read their own devices"
  ON devices FOR SELECT
  USING (auth.uid() = profile_id);

CREATE POLICY "Users can create their own devices"
  ON devices FOR INSERT
  WITH CHECK (auth.uid() = profile_id);

CREATE POLICY "Users can update their own devices"
  ON devices FOR UPDATE
  USING (auth.uid() = profile_id);

-- RLS Policies for policies
CREATE POLICY "Users can read their own policies"
  ON policies FOR SELECT
  USING (auth.uid() = owner_profile_id);

CREATE POLICY "Users can create their own policies"
  ON policies FOR INSERT
  WITH CHECK (auth.uid() = owner_profile_id);

CREATE POLICY "Users can update their own policies"
  ON policies FOR UPDATE
  USING (auth.uid() = owner_profile_id);

CREATE POLICY "Parents can read child policies"
  ON policies FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM family_members
      WHERE family_members.parent_id = auth.uid()
      AND family_members.child_id = policies.owner_profile_id
    )
  );

-- RLS Policies for relapse_events
CREATE POLICY "Users can read their own relapse events"
  ON relapse_events FOR SELECT
  USING (auth.uid() = profile_id);

CREATE POLICY "Users can insert their own relapse events"
  ON relapse_events FOR INSERT
  WITH CHECK (auth.uid() = profile_id);

-- RLS Policies for accountability_summaries
CREATE POLICY "Users can read their own accountability summaries"
  ON accountability_summaries FOR SELECT
  USING (auth.uid() = profile_id);

CREATE POLICY "Partners can read linked accountability summaries"
  ON accountability_summaries FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM accountability_links
      WHERE accountability_links.owner_profile_id = accountability_summaries.profile_id
      AND accountability_links.partner_email = (SELECT email FROM profiles WHERE id = auth.uid())
    )
  );
