import '../models/challenge_model.dart';
import 'crypto_service.dart';
import 'supabase_service.dart';

class ChallengeService {
  static final _client = SupabaseService.client;

  /// Create a challenge and invite an opponent
  static Future<Challenge> createChallenge({
    required String title,
    String? description,
    required String challengeType,
    required int targetValue,
    required int durationDays,
    required String opponentId,
  }) async {
    final uid = SupabaseService.currentUser!.id;
    final start = DateTime.now();
    final end = start.add(Duration(days: durationDays - 1));

    final row = await _client.from('challenges').insert({
      'creator_id': uid,
      'title': CryptoService.encrypt(title),
      'description': CryptoService.encryptNullable(description),
      'challenge_type': challengeType,
      'target_value': targetValue,
      'start_date': _dateStr(start),
      'end_date': _dateStr(end),
      'status': 'pending',
    }).select().single();

    final challengeId = row['id'] as String;

    // Add creator as accepted participant
    await _client.from('challenge_participants').insert({
      'challenge_id': challengeId,
      'user_id': uid,
      'status': 'accepted',
    });

    // Invite opponent
    await _client.from('challenge_participants').insert({
      'challenge_id': challengeId,
      'user_id': opponentId,
      'status': 'invited',
    });

    return Challenge.fromMap(row);
  }

  /// Load all challenges involving the current user (with participants + profiles)
  static Future<List<Challenge>> loadMyChallenges() async {
    final uid = SupabaseService.currentUser!.id;

    // Get challenge IDs where user is a participant
    final partRows = List<Map<String, dynamic>>.from(
      await _client
          .from('challenge_participants')
          .select('challenge_id')
          .eq('user_id', uid) as List,
    );
    final ids = partRows.map((r) => r['challenge_id'] as String).toList();
    if (ids.isEmpty) return [];

    // Get challenges
    final challengeRows = List<Map<String, dynamic>>.from(
      await _client
          .from('challenges')
          .select()
          .inFilter('id', ids)
          .order('created_at', ascending: false) as List,
    );

    // Get all participants + profiles for these challenges
    final allParts = List<Map<String, dynamic>>.from(
      await _client
          .from('challenge_participants')
          .select('*, profiles(username, display_name)')
          .inFilter('challenge_id', ids) as List,
    );

    return challengeRows.map((c) {
      final decrypted = Map<String, dynamic>.from(c)
        ..['title'] = CryptoService.decrypt(c['title'] as String? ?? '')
        ..['description'] = CryptoService.decryptNullable(c['description'] as String?);
      final cId = c['id'] as String;
      final parts = allParts
          .where((p) => p['challenge_id'] == cId)
          .map((p) => ChallengeParticipant.fromMap(p))
          .toList();
      return Challenge.fromMap(decrypted, participants: parts);
    }).toList();
  }

  /// Accept or reject a challenge invitation
  static Future<void> respondToChallenge(
      String challengeId, bool accept) async {
    final uid = SupabaseService.currentUser!.id;
    await _client
        .from('challenge_participants')
        .update({'status': accept ? 'accepted' : 'rejected'})
        .eq('challenge_id', challengeId)
        .eq('user_id', uid);
    // Challenge status is activated automatically by DB trigger on_participant_accepted
  }

  /// Update current user's progress in a challenge (only when active)
  static Future<void> updateProgress(String challengeId, int value) async {
    final uid = SupabaseService.currentUser!.id;
    final challenge = await _client
        .from('challenges')
        .select('status')
        .eq('id', challengeId)
        .single();
    if (challenge['status'] != 'active') return;
    await _client
        .from('challenge_participants')
        .update({'current_value': value})
        .eq('challenge_id', challengeId)
        .eq('user_id', uid);
  }

  /// Delete a challenge (creator only, pending challenges)
  static Future<void> deleteChallenge(String challengeId) async {
    await _client.from('challenges').delete().eq('id', challengeId);
  }

  /// Update challenge title and description (creator only)
  static Future<void> updateChallengeInfo(
      String challengeId, String title, String? description) async {
    await _client.from('challenges').update({
      'title': CryptoService.encrypt(title),
      'description': CryptoService.encryptNullable(description),
    }).eq('id', challengeId);
  }

  static String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
