-- ============================================================
-- Twin'Am - Twin Friends Schema
-- Run this in your Supabase SQL Editor
-- ============================================================

-- 1. PROFILES (extends auth.users)
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  username text unique not null,
  display_name text,
  avatar_url text,
  created_at timestamp with time zone default now() not null
);

alter table public.profiles enable row level security;

create policy "Profiles viewable by everyone" on public.profiles
  for select using (true);

create policy "Users can insert their own profile" on public.profiles
  for insert with check (auth.uid() = id);

create policy "Users can update their own profile" on public.profiles
  for update using (auth.uid() = id);

-- 2. FRIENDSHIPS
create table if not exists public.friendships (
  id uuid default gen_random_uuid() primary key,
  requester_id uuid references public.profiles(id) on delete cascade not null,
  addressee_id uuid references public.profiles(id) on delete cascade not null,
  status text check (status in ('pending', 'accepted', 'rejected')) default 'pending' not null,
  created_at timestamp with time zone default now() not null,
  unique(requester_id, addressee_id)
);

alter table public.friendships enable row level security;

create policy "Users can see their own friendships" on public.friendships
  for select using (auth.uid() = requester_id or auth.uid() = addressee_id);

create policy "Users can send friend requests" on public.friendships
  for insert with check (auth.uid() = requester_id);

create policy "Users can update their received requests" on public.friendships
  for update using (auth.uid() = addressee_id);

create policy "Users can delete their own friendships" on public.friendships
  for delete using (auth.uid() = requester_id or auth.uid() = addressee_id);

-- 3. CHALLENGES
create table if not exists public.challenges (
  id uuid default gen_random_uuid() primary key,
  creator_id uuid references public.profiles(id) on delete cascade not null,
  title text not null,
  description text,
  challenge_type text check (challenge_type in ('streak', 'goal_count', 'total_value')) default 'streak' not null,
  target_value int not null,
  start_date date not null,
  end_date date not null,
  status text check (status in ('pending', 'active', 'completed', 'cancelled')) default 'pending' not null,
  created_at timestamp with time zone default now() not null
);

alter table public.challenges enable row level security;

create policy "Users can create challenges" on public.challenges
  for insert with check (auth.uid() = creator_id);

create policy "Creator can update challenge" on public.challenges
  for update using (auth.uid() = creator_id);

create policy "Creator can delete challenge" on public.challenges
  for delete using (auth.uid() = creator_id);

-- 4. CHALLENGE PARTICIPANTS
create table if not exists public.challenge_participants (
  id uuid default gen_random_uuid() primary key,
  challenge_id uuid references public.challenges(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  status text check (status in ('invited', 'accepted', 'rejected')) default 'invited' not null,
  current_value int default 0 not null,
  joined_at timestamp with time zone default now() not null,
  unique(challenge_id, user_id)
);

alter table public.challenge_participants enable row level security;

-- SECURITY DEFINER function: checks participation WITHOUT applying RLS (breaks the recursion cycle)
create or replace function public.is_challenge_participant(p_challenge_id uuid, p_user_id uuid)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1 from public.challenge_participants
    where challenge_id = p_challenge_id and user_id = p_user_id
  );
$$;

-- challenge_participants SELECT: any participant can see ALL rows for their shared challenges
-- Uses SECURITY DEFINER function to avoid RLS recursion
create policy "Participants viewable by challenge members" on public.challenge_participants
  for select using (
    public.is_challenge_participant(challenge_id, auth.uid())
  );

create policy "Creator can add participants" on public.challenge_participants
  for insert with check (
    exists (select 1 from public.challenges where id = challenge_id and creator_id = auth.uid())
  );

create policy "Users can update their own participation" on public.challenge_participants
  for update using (auth.uid() = user_id);

-- challenges SELECT: uses SECURITY DEFINER function to check participation (no RLS recursion)
create policy "Challenges viewable by participants" on public.challenges
  for select using (
    creator_id = auth.uid()
    or public.is_challenge_participant(id, auth.uid())
  );

-- 5b. Trigger: auto-activate challenge when invited participant accepts
create or replace function public.handle_participant_accepted()
returns trigger as $$
begin
  if NEW.status = 'accepted' and OLD.status = 'invited' then
    update public.challenges
    set status = 'active'
    where id = NEW.challenge_id;
  end if;
  return NEW;
end;
$$ language plpgsql security definer;

create or replace trigger on_participant_accepted
  after update of status on public.challenge_participants
  for each row execute procedure public.handle_participant_accepted();

-- 5. Function: auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email, '@', 1))
  );
  return new;
end;
$$ language plpgsql security definer;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
