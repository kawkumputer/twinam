enum AchievementType {
  firstTap,
  first100,
  first1000,
  first10000,
  streak3,
  streak7,
  streak14,
  streak30,
  streak100,
  counter5,
  counter10,
  goalFirst,
  goal10,
  goal50,
  nightOwl,
  earlyBird,
  weekendWarrior,
}

class Achievement {
  final AchievementType type;
  final String titleKey;
  final String descriptionKey;
  final String icon;
  final DateTime? unlockedAt;

  const Achievement({
    required this.type,
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  Achievement unlock() {
    return Achievement(
      type: type,
      titleKey: titleKey,
      descriptionKey: descriptionKey,
      icon: icon,
      unlockedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  static Achievement fromJson(Map<String, dynamic> json, Achievement template) {
    return Achievement(
      type: template.type,
      titleKey: template.titleKey,
      descriptionKey: template.descriptionKey,
      icon: template.icon,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }

  static final List<Achievement> all = [
    const Achievement(
      type: AchievementType.firstTap,
      titleKey: 'achFirstTap',
      descriptionKey: 'achFirstTapDesc',
      icon: '👆',
    ),
    const Achievement(
      type: AchievementType.first100,
      titleKey: 'achFirst100',
      descriptionKey: 'achFirst100Desc',
      icon: '💯',
    ),
    const Achievement(
      type: AchievementType.first1000,
      titleKey: 'achFirst1000',
      descriptionKey: 'achFirst1000Desc',
      icon: '🔥',
    ),
    const Achievement(
      type: AchievementType.first10000,
      titleKey: 'achFirst10000',
      descriptionKey: 'achFirst10000Desc',
      icon: '⚡',
    ),
    const Achievement(
      type: AchievementType.streak3,
      titleKey: 'achStreak3',
      descriptionKey: 'achStreak3Desc',
      icon: '🌱',
    ),
    const Achievement(
      type: AchievementType.streak7,
      titleKey: 'achStreak7',
      descriptionKey: 'achStreak7Desc',
      icon: '🌿',
    ),
    const Achievement(
      type: AchievementType.streak14,
      titleKey: 'achStreak14',
      descriptionKey: 'achStreak14Desc',
      icon: '🌳',
    ),
    const Achievement(
      type: AchievementType.streak30,
      titleKey: 'achStreak30',
      descriptionKey: 'achStreak30Desc',
      icon: '🏆',
    ),
    const Achievement(
      type: AchievementType.streak100,
      titleKey: 'achStreak100',
      descriptionKey: 'achStreak100Desc',
      icon: '👑',
    ),
    const Achievement(
      type: AchievementType.counter5,
      titleKey: 'achCounter5',
      descriptionKey: 'achCounter5Desc',
      icon: '📊',
    ),
    const Achievement(
      type: AchievementType.counter10,
      titleKey: 'achCounter10',
      descriptionKey: 'achCounter10Desc',
      icon: '🗂️',
    ),
    const Achievement(
      type: AchievementType.goalFirst,
      titleKey: 'achGoalFirst',
      descriptionKey: 'achGoalFirstDesc',
      icon: '🎯',
    ),
    const Achievement(
      type: AchievementType.goal10,
      titleKey: 'achGoal10',
      descriptionKey: 'achGoal10Desc',
      icon: '🏅',
    ),
    const Achievement(
      type: AchievementType.goal50,
      titleKey: 'achGoal50',
      descriptionKey: 'achGoal50Desc',
      icon: '🥇',
    ),
    const Achievement(
      type: AchievementType.nightOwl,
      titleKey: 'achNightOwl',
      descriptionKey: 'achNightOwlDesc',
      icon: '🦉',
    ),
    const Achievement(
      type: AchievementType.earlyBird,
      titleKey: 'achEarlyBird',
      descriptionKey: 'achEarlyBirdDesc',
      icon: '🐦',
    ),
    const Achievement(
      type: AchievementType.weekendWarrior,
      titleKey: 'achWeekendWarrior',
      descriptionKey: 'achWeekendWarriorDesc',
      icon: '💪',
    ),
  ];
}
