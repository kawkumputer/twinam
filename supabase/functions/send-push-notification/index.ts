import { serve } from 'https://deno.land/std@0.208.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// ── Google Service Account JWT helpers ────────────────────────────────────────

function b64url(data: unknown): string {
  return btoa(JSON.stringify(data))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');
}

async function createServiceAccountJWT(
  clientEmail: string,
  privateKeyPem: string,
): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: 'RS256', typ: 'JWT' };
  const payload = {
    iss: clientEmail,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
  };

  const signingInput = `${b64url(header)}.${b64url(payload)}`;

  const pemContents = privateKeyPem
    .replace(/-----BEGIN PRIVATE KEY-----/g, '')
    .replace(/-----END PRIVATE KEY-----/g, '')
    .replace(/\n/g, '');

  const binaryKey = Uint8Array.from(atob(pemContents), (c) => c.charCodeAt(0));

  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8',
    binaryKey,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );

  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    new TextEncoder().encode(signingInput),
  );

  const signatureB64 = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');

  return `${signingInput}.${signatureB64}`;
}

async function getFCMAccessToken(serviceAccountJson: string): Promise<string> {
  const sa = JSON.parse(serviceAccountJson);
  const jwt = await createServiceAccountJWT(sa.client_email, sa.private_key);

  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });

  const json = await res.json();
  if (!json.access_token) {
    throw new Error(`Failed to get access token: ${JSON.stringify(json)}`);
  }
  return json.access_token as string;
}

// ── FCM v1 send ────────────────────────────────────────────────────────────────

async function sendFCMPush(
  accessToken: string,
  projectId: string,
  fcmToken: string,
  title: string,
  body: string,
  data: Record<string, string>,
): Promise<void> {
  const url = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;
  const res = await fetch(url, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      message: {
        token: fcmToken,
        notification: { title, body },
        data,
        android: { priority: 'high' },
        apns: {
          headers: { 'apns-priority': '10' },
          payload: { aps: { sound: 'default', badge: 1 } },
        },
      },
    }),
  });

  if (!res.ok) {
    const err = await res.text();
    throw new Error(`FCM send failed (${res.status}): ${err}`);
  }
  console.log('[FCM] Push sent successfully');
}

// ── Main handler ──────────────────────────────────────────────────────────────

serve(async (req) => {
  try {
    const serviceAccountJson = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON');
    const projectId = Deno.env.get('FIREBASE_PROJECT_ID');
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

    if (!serviceAccountJson || !projectId) {
      return new Response('Missing Firebase config', { status: 500 });
    }

    const webhookPayload = await req.json();
    const table: string = webhookPayload.table;
    const record = webhookPayload.record;

    if (!record) {
      return new Response('No record', { status: 400 });
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);
    let recipientId: string | null = null;
    let title = '';
    let body = '';
    let notifData: Record<string, string> = {};

    // ── Friend request ──────────────────────────────────────────────────────
    if (table === 'friendships' && record.status === 'pending') {
      recipientId = record.addressee_id as string;
      const requesterId = record.requester_id as string;

      const { data: profile } = await supabase
        .from('profiles')
        .select('display_name, username')
        .eq('id', requesterId)
        .single();

      const senderName =
        (profile?.display_name as string | null)?.trim() ||
        (profile?.username as string | null) ||
        'Someone';

      title = `👥 ${senderName}`;
      body = 'Veut être ton ami · Wants to be friends';
      notifData = { type: 'friend_request', sender_name: senderName };
    }

    // ── Challenge invite ────────────────────────────────────────────────────
    else if (table === 'challenge_participants' && record.status === 'invited') {
      recipientId = record.user_id as string;
      const challengeId = record.challenge_id as string;

      const { data: challenge } = await supabase
        .from('challenges')
        .select('title, creator_id')
        .eq('id', challengeId)
        .single();

      const { data: creator } = await supabase
        .from('profiles')
        .select('display_name, username')
        .eq('id', challenge?.creator_id)
        .single();

      const creatorName =
        (creator?.display_name as string | null)?.trim() ||
        (creator?.username as string | null) ||
        'Someone';
      const challengeTitle = (challenge?.title as string | null) || 'Challenge';

      title = `⚡ ${creatorName} te défie !`;
      body = challengeTitle;
      notifData = {
        type: 'challenge_invite',
        sender_name: creatorName,
        challenge_title: challengeTitle,
      };
    } else {
      return new Response('Unhandled event', { status: 200 });
    }

    if (!recipientId) {
      return new Response('No recipient', { status: 400 });
    }

    // Get recipient FCM token
    const { data: recipientProfile } = await supabase
      .from('profiles')
      .select('fcm_token')
      .eq('id', recipientId)
      .single();

    const fcmToken = recipientProfile?.fcm_token as string | null;
    if (!fcmToken) {
      console.log(`[FCM] No token for recipient: ${recipientId}`);
      return new Response('No FCM token', { status: 200 });
    }

    const accessToken = await getFCMAccessToken(serviceAccountJson);
    await sendFCMPush(accessToken, projectId, fcmToken, title, body, notifData);

    return new Response(JSON.stringify({ success: true }), {
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (err) {
    console.error('[FCM] Error:', err);
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
});
