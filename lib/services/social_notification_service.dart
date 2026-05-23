import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';
import 'supabase_service.dart';

class SocialNotificationService {
  static final SocialNotificationService _instance =
      SocialNotificationService._internal();
  factory SocialNotificationService() => _instance;
  SocialNotificationService._internal();

  RealtimeChannel? _friendChannel;
  RealtimeChannel? _challengeChannel;
  StreamSubscription<RemoteMessage>? _fcmForegroundSub;
  StreamSubscription<String>? _tokenRefreshSub;
  bool _initialized = false;

  /// Called at app startup if user is already logged in.
  Future<void> initIfLoggedIn() async {
    if (kIsWeb) return;
    if (SupabaseService.currentUser != null) {
      await init();
    }
  }

  /// Call after a successful login.
  Future<void> init() async {
    if (kIsWeb || _initialized) return;
    final uid = SupabaseService.currentUser?.id;
    if (uid == null) return;

    _initialized = true;
    await _requestPermissionAndSaveToken(uid);
    _setupFCMHandlers();
    _subscribeFriendRequests(uid);
    _subscribeChallengeInvites(uid);
    debugPrint('[SocialNotif] Initialized for user: $uid');
  }

  /// Call on sign out to clean up subscriptions.
  Future<void> dispose() async {
    _initialized = false;
    await _friendChannel?.unsubscribe();
    await _challengeChannel?.unsubscribe();
    await _fcmForegroundSub?.cancel();
    await _tokenRefreshSub?.cancel();
    _friendChannel = null;
    _challengeChannel = null;
    _fcmForegroundSub = null;
    _tokenRefreshSub = null;
    debugPrint('[SocialNotif] Disposed');
  }

  // ── FCM Token ──────────────────────────────────────────────────────────────

  Future<void> _requestPermissionAndSaveToken(String uid) async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('[SocialNotif] FCM permission: ${settings.authorizationStatus}');

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _saveToken(uid, token);
      }

      _tokenRefreshSub =
          FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        _saveToken(uid, newToken);
      });
    } catch (e) {
      debugPrint('[SocialNotif] Failed to get/save FCM token: $e');
    }
  }

  Future<void> _saveToken(String uid, String token) async {
    try {
      await SupabaseService.client
          .from('profiles')
          .update({'fcm_token': token})
          .eq('id', uid);
      debugPrint('[SocialNotif] FCM token saved');
    } catch (e) {
      debugPrint('[SocialNotif] Failed to save FCM token: $e');
    }
  }

  // ── FCM Foreground + Tap Handlers ──────────────────────────────────────────

  void _setupFCMHandlers() {
    // Foreground: FCM delivers data-only, show local notification
    _fcmForegroundSub = FirebaseMessaging.onMessage.listen((message) {
      final type = message.data['type'] as String?;
      final senderName = message.data['sender_name'] as String? ?? '';
      final challengeTitle = message.data['challenge_title'] as String? ?? '';

      if (type == 'friend_request') {
        NotificationService().showFriendRequestNotification(senderName);
      } else if (type == 'challenge_invite') {
        NotificationService()
            .showChallengeInviteNotification(senderName, challengeTitle);
      }
    });

    // Background tap: user tapped the notification while app was in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleFCMTap);

    // Cold-start tap: user tapped notification that launched the app
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) _handleFCMTap(message);
    });
  }

  void _handleFCMTap(RemoteMessage message) {
    final type = message.data['type'] as String?;
    final nav = NotificationService.navigatorKey.currentState;
    if (nav == null) return;

    if (type == 'friend_request') {
      nav.pushNamed('/friends');
    } else if (type == 'challenge_invite') {
      nav.pushNamed('/friends', arguments: 1);
    }
  }

  // ── Supabase Realtime ──────────────────────────────────────────────────────

  void _subscribeFriendRequests(String userId) {
    _friendChannel = SupabaseService.client
        .channel('friend_requests_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'friendships',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'addressee_id',
            value: userId,
          ),
          callback: (payload) async {
            final requesterId =
                payload.newRecord['requester_id'] as String?;
            if (requesterId == null) return;
            try {
              final profile = await SupabaseService.client
                  .from('profiles')
                  .select('display_name, username')
                  .eq('id', requesterId)
                  .single();
              final name = (profile['display_name'] as String?)?.isNotEmpty == true
                  ? profile['display_name'] as String
                  : (profile['username'] as String?) ?? 'Someone';
              NotificationService().showFriendRequestNotification(name);
            } catch (_) {
              NotificationService().showFriendRequestNotification('Someone');
            }
          },
        )
        .subscribe();
    debugPrint('[SocialNotif] Subscribed to friend requests for: $userId');
  }

  void _subscribeChallengeInvites(String userId) {
    _challengeChannel = SupabaseService.client
        .channel('challenge_invites_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'challenge_participants',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) async {
            final record = payload.newRecord;
            if (record['status'] != 'invited') return;
            final challengeId = record['challenge_id'] as String?;
            if (challengeId == null) return;
            try {
              final challenge = await SupabaseService.client
                  .from('challenges')
                  .select('title, creator_id')
                  .eq('id', challengeId)
                  .single();
              final creatorProfile = await SupabaseService.client
                  .from('profiles')
                  .select('display_name, username')
                  .eq('id', challenge['creator_id'] as String)
                  .single();
              final name =
                  (creatorProfile['display_name'] as String?)?.isNotEmpty == true
                      ? creatorProfile['display_name'] as String
                      : (creatorProfile['username'] as String?) ?? 'Someone';
              final title =
                  (challenge['title'] as String?) ?? 'Challenge';
              NotificationService()
                  .showChallengeInviteNotification(name, title);
            } catch (_) {
              NotificationService()
                  .showChallengeInviteNotification('Someone', 'Challenge');
            }
          },
        )
        .subscribe();
    debugPrint('[SocialNotif] Subscribed to challenge invites for: $userId');
  }
}
