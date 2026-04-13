class ChallengeParticipant {
  final String id;
  final String challengeId;
  final String userId;
  final String status; // invited | accepted | rejected
  final int currentValue;
  final DateTime joinedAt;

  // Joined from profiles
  final String? username;
  final String? displayName;

  const ChallengeParticipant({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.status,
    required this.currentValue,
    required this.joinedAt,
    this.username,
    this.displayName,
  });

  factory ChallengeParticipant.fromMap(Map<String, dynamic> m) {
    final profile = m['profiles'] as Map<String, dynamic>?;
    return ChallengeParticipant(
      id: m['id'] as String,
      challengeId: m['challenge_id'] as String,
      userId: m['user_id'] as String,
      status: m['status'] as String,
      currentValue: (m['current_value'] as int?) ?? 0,
      joinedAt: DateTime.parse(m['joined_at'] as String),
      username: profile?['username'] as String?,
      displayName: profile?['display_name'] as String?,
    );
  }
}

class Challenge {
  final String id;
  final String creatorId;
  final String title;
  final String? description;
  final String challengeType; // streak | goal_count | total_value
  final int targetValue;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // pending | active | completed | cancelled
  final DateTime createdAt;

  // Joined
  final List<ChallengeParticipant> participants;

  const Challenge({
    required this.id,
    required this.creatorId,
    required this.title,
    this.description,
    required this.challengeType,
    required this.targetValue,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    this.participants = const [],
  });

  factory Challenge.fromMap(Map<String, dynamic> m,
      {List<ChallengeParticipant> participants = const []}) {
    return Challenge(
      id: m['id'] as String,
      creatorId: m['creator_id'] as String,
      title: m['title'] as String,
      description: m['description'] as String?,
      challengeType: m['challenge_type'] as String,
      targetValue: m['target_value'] as int,
      startDate: DateTime.parse(m['start_date'] as String),
      endDate: DateTime.parse(m['end_date'] as String),
      status: m['status'] as String,
      createdAt: DateTime.parse(m['created_at'] as String),
      participants: participants,
    );
  }

  int get durationDays => endDate.difference(startDate).inDays + 1;

  bool get isPending => status == 'pending';
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
}
