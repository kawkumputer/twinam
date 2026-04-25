-- Add XP and Level columns to profiles for leaderboard
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS xp    INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS level INTEGER NOT NULL DEFAULT 1;

-- Index for fast leaderboard queries (ordered by XP desc)
CREATE INDEX IF NOT EXISTS idx_profiles_xp ON profiles(xp DESC);

-- RLS: users can update their own xp/level
-- (existing RLS policy on profiles already covers this via auth.uid() = id)
