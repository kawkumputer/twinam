import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart' as crypto_pkg;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/twin_user.dart';
import 'supabase_service.dart';

class AuthService {
  final _client = SupabaseService.client;

  // ─── IMPORTANT: fill these in from Google Cloud Console ───────────────────
  // 1. Create OAuth 2.0 credentials (Web + iOS) at console.cloud.google.com
  // 2. Enable Google provider in Supabase Dashboard → Auth → Providers
  // 3. Put google-services.json in android/app/
  // 4. Add reversed iOS client ID to Info.plist CFBundleURLSchemes
  // ──────────────────────────────────────────────────────────────────────────
  static const _googleWebClientId =
      'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
  static const _googleIosClientId =
      'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com';

  Future<TwinUser> signUp({
    required String email,
    required String password,
    required String username,
    String? displayName,
  }) async {
    final trimmedUsername = username.trim().toLowerCase();

    final existing = await _client
        .from('profiles')
        .select('id')
        .eq('username', trimmedUsername)
        .maybeSingle();

    if (existing != null) throw 'Ce nom d\'utilisateur est déjà pris';

    final res = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'username': trimmedUsername,
        'display_name': displayName?.trim() ?? trimmedUsername,
      },
    );

    if (res.user == null) throw 'Erreur lors de l\'inscription';

    // If no session, email confirmation is required
    if (res.session == null) throw 'EMAIL_CONFIRMATION_REQUIRED';

    await Future.delayed(const Duration(milliseconds: 500));
    return await _getOrCreateProfile(res.user!, trimmedUsername, displayName);
  }

  Future<TwinUser> signIn({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    if (res.user == null) throw 'Email ou mot de passe incorrect';
    return await getProfile(res.user!.id);
  }

  Future<TwinUser> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      clientId: _googleIosClientId,
      serverClientId: _googleWebClientId,
    );
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw 'Connexion annulée';
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) throw 'Token Google manquant';
    final res = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: googleAuth.accessToken,
    );
    if (res.user == null) throw 'Erreur de connexion Google';
    final username = googleUser.email
        .split('@')[0]
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    return await _getOrCreateProfile(
        res.user!, username, googleUser.displayName);
  }

  // ─── IMPORTANT: Apple Sign-In setup ───────────────────────────────────────
  // 1. Enable Apple provider in Supabase Dashboard → Auth → Providers
  // 2. Apple Developer Portal → Identifiers → create a Service ID
  // 3. Apple Developer Portal → Keys → create key with Sign in with Apple
  // 4. Xcode → Signing & Capabilities → add "Sign in with Apple"
  // ──────────────────────────────────────────────────────────────────────────
  Future<TwinUser> signInWithApple() async {
    final rawNonce = _generateNonce();
    final hashedNonce = _sha256ofString(rawNonce);
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );
    final idToken = credential.identityToken;
    if (idToken == null) throw 'Token Apple manquant';
    final res = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
    if (res.user == null) throw 'Erreur de connexion Apple';
    final email = res.user!.email ?? '';
    final username = email.isNotEmpty
        ? email.split('@')[0].replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
        : 'user_${res.user!.id.substring(0, 8)}';
    final displayName = [
      credential.givenName,
      credential.familyName,
    ].where((n) => n != null && n.isNotEmpty).join(' ');
    return await _getOrCreateProfile(
        res.user!, username, displayName.isEmpty ? null : displayName);
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
        length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = crypto_pkg.sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> deleteAccount() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;

    bool rpcSuccess = false;
    try {
      // Preferred: single SECURITY DEFINER function bypasses all RLS policies
      // and also deletes the auth.users row.
      // Run supabase/migrations/20260415_delete_user_account.sql first.
      await _client.rpc('delete_user_account');
      rpcSuccess = true;
    } catch (_) {}

    if (!rpcSuccess) {
      // Fallback: manual deletion (requires matching RLS DELETE policies)
      try {
        await _client
            .from('challenge_participants')
            .delete()
            .eq('user_id', uid);
      } catch (_) {}
      try {
        await _client
            .from('friendships')
            .delete()
            .or('requester_id.eq.$uid,addressee_id.eq.$uid');
      } catch (_) {}
      try {
        await _client.from('challenges').delete().eq('creator_id', uid);
      } catch (_) {}
      try {
        await _client.from('profiles').delete().eq('id', uid);
      } catch (_) {}
    }

    await _client.auth.signOut();
  }

  /// Sync local XP and level to Supabase (for leaderboard)
  Future<void> syncXp(int xp, int level) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await _client
          .from('profiles')
          .update({'xp': xp, 'level': level})
          .eq('id', uid);
    } catch (e) {
      // Silent fail – leaderboard sync is best-effort
    }
  }

  /// Fetch leaderboard: current user + their accepted friends, ordered by XP
  Future<List<Map<String, dynamic>>> fetchLeaderboard() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];

    // Get accepted friend IDs
    final friendships = List<Map<String, dynamic>>.from(
      await _client
          .from('friendships')
          .select('requester_id, addressee_id')
          .or('requester_id.eq.$uid,addressee_id.eq.$uid')
          .eq('status', 'accepted') as List,
    );
    final friendIds = friendships
        .map((f) => f['requester_id'] == uid
            ? f['addressee_id'] as String
            : f['requester_id'] as String)
        .toList();

    // Include self
    final allIds = [uid, ...friendIds];

    final profiles = List<Map<String, dynamic>>.from(
      await _client
          .from('profiles')
          .select('id, username, display_name, xp, level')
          .inFilter('id', allIds)
          .order('xp', ascending: false) as List,
    );

    return profiles;
  }

  Future<TwinUser> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return TwinUser.fromJson({
      ...data,
      'email': _client.auth.currentUser?.email ?? '',
    });
  }

  Future<TwinUser> verifyOtp({
    required String email,
    required String token,
  }) async {
    final res = await _client.auth.verifyOTP(
      email: email.trim(),
      token: token.trim(),
      type: OtpType.signup,
    );
    if (res.session == null) throw 'Code invalide ou expiré';
    await Future.delayed(const Duration(milliseconds: 300));
    final username = res.user?.userMetadata?['username'] as String? ??
        email.split('@')[0];
    final displayName = res.user?.userMetadata?['display_name'] as String?;
    return await _getOrCreateProfile(res.user!, username, displayName);
  }

  Future<TwinUser?> getCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    try {
      return await getProfile(user.id);
    } catch (_) {
      return null;
    }
  }

  Future<TwinUser> _getOrCreateProfile(
    User user,
    String username,
    String? displayName,
  ) async {
    try {
      return await getProfile(user.id);
    } catch (_) {
      await _client.from('profiles').insert({
        'id': user.id,
        'username': username,
        'display_name': displayName?.trim() ?? username,
      });
      return await getProfile(user.id);
    }
  }
}
