import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/twin_user.dart';
import 'supabase_service.dart';

class AuthService {
  final _client = SupabaseService.client;

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

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> deleteAccount() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;

    try {
      await _client
          .from('challenge_participants')
          .delete()
          .eq('user_id', uid);
      await _client
          .from('friendships')
          .delete()
          .or('requester_id.eq.$uid,addressee_id.eq.$uid');
      await _client.from('challenges').delete().eq('creator_id', uid);
      await _client.from('profiles').delete().eq('id', uid);
      // Delete the auth user via a SECURITY DEFINER DB function (if set up)
      try {
        await _client.rpc('delete_user_account');
      } catch (_) {}
    } catch (_) {}

    await _client.auth.signOut();
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
