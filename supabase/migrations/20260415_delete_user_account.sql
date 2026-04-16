-- Function: delete_user_account
-- Called by authenticated users to delete their own account.
-- SECURITY DEFINER bypasses all RLS policies.
-- Run this once in Supabase SQL Editor.

CREATE OR REPLACE FUNCTION public.delete_user_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid := auth.uid();
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  DELETE FROM public.challenge_participants WHERE user_id = uid;
  DELETE FROM public.friendships
    WHERE requester_id = uid OR addressee_id = uid;
  DELETE FROM public.challenges WHERE creator_id = uid;
  DELETE FROM public.profiles WHERE id = uid;
  DELETE FROM auth.users WHERE id = uid;
END;
$$;

-- Allow any authenticated user to call this function
GRANT EXECUTE ON FUNCTION public.delete_user_account() TO authenticated;
