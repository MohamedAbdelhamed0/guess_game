-- ============================================================================
-- ULTIMATE GUESS GAME — SUPABASE BACKEND SCHEMA & REALTIME SETUP
-- Run this complete SQL script in your Supabase Dashboard -> SQL Editor.
-- ============================================================================

-- 1. CLEANUP PREVIOUS TABLES (If starting fresh)
DROP TABLE IF EXISTS public.players CASCADE;
DROP TABLE IF EXISTS public.rooms CASCADE;

-- 2. CREATE ROOMS TABLE
CREATE TABLE public.rooms (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_code   text UNIQUE NOT NULL,                      -- 6-character room key (e.g. 'ABC123')
  host_id     text NOT NULL,                             -- user ID of room creator
  status      text NOT NULL DEFAULT 'waiting',           -- 'waiting' | 'playing' | 'ended'
  revealed    boolean DEFAULT false,                     -- Host toggles revealing both photos
  created_at  timestamptz DEFAULT now()
);

-- 3. CREATE PLAYERS TABLE (Max 2 players per room)
CREATE TABLE public.players (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id       uuid REFERENCES public.rooms(id) ON DELETE CASCADE NOT NULL,
  user_id       text NOT NULL,                           -- user ID
  display_name  text NOT NULL,                           -- Player display name
  photo_url     text,                                    -- Secret photo assigned TO this player to guess
  score         int DEFAULT 0,                           -- Current player score
  is_host       boolean DEFAULT false,                   -- Is player the room host
  joined_at     timestamptz DEFAULT now(),

  UNIQUE(room_id, user_id)                               -- One entry per user per room
);

-- 4. ENABLE ROW LEVEL SECURITY (RLS)
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.players ENABLE ROW LEVEL SECURITY;

-- 5. RLS POLICIES — ROOMS
-- Allow anyone to view rooms (to find and join by room code)
CREATE POLICY "Allow public read on rooms" ON public.rooms
  FOR SELECT USING (true);

-- Allow creating rooms
CREATE POLICY "Allow insert on rooms" ON public.rooms
  FOR INSERT WITH CHECK (true);

-- Allow updating rooms (for status transitions)
CREATE POLICY "Allow update on rooms" ON public.rooms
  FOR UPDATE USING (true);

-- 6. RLS POLICIES — PLAYERS
-- Allow reading players in rooms
CREATE POLICY "Allow public read on players" ON public.players
  FOR SELECT USING (true);

-- Allow players to join rooms
CREATE POLICY "Allow insert on players" ON public.players
  FOR INSERT WITH CHECK (true);

-- Allow updating player records (for assigning photos and updating scores)
CREATE POLICY "Allow update on players" ON public.players
  FOR UPDATE USING (true);

-- Allow removing players
CREATE POLICY "Allow delete on players" ON public.players
  FOR DELETE USING (true);

-- 7. ENABLE REALTIME PUBLICATION FOR LIVE GAME SYNC
ALTER PUBLICATION supabase_realtime ADD TABLE public.rooms;
ALTER PUBLICATION supabase_realtime ADD TABLE public.players;

-- 8. STORAGE BUCKET CONFIGURATION FOR GAME PHOTOS
-- Ensure 'game-photos' bucket exists and is public
INSERT INTO storage.buckets (id, name, public)
VALUES ('game-photos', 'game-photos', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- Storage policies for game-photos bucket
CREATE POLICY "Allow public upload to game-photos" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'game-photos');

CREATE POLICY "Allow public read from game-photos" ON storage.objects
  FOR SELECT USING (bucket_id = 'game-photos');

CREATE POLICY "Allow public update in game-photos" ON storage.objects
  FOR UPDATE USING (bucket_id = 'game-photos');

CREATE POLICY "Allow public delete in game-photos" ON storage.objects
  FOR DELETE USING (bucket_id = 'game-photos');
