import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../models/counter.dart';
import '../services/storage_service.dart';

class AchievementProvider extends ChangeNotifier {
  final StorageService _storage;
  List<Achievement> _achievements = [];
  Achievement? _lastUnlocked;
  bool _didLevelUp = false;
  int? _milestone;

  AchievementProvider(this._storage) {
    _loadAchievements();
  }

  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();
  Achievement? get lastUnlocked => _lastUnlocked;
  int get totalTaps => _storage.totalTaps;
  int get daysActive => _storage.daysActive;
  int get goalsCompleted => _storage.goalsCompleted;

  // XP & Level
  int get xp => _storage.xp;
  int get level => _storage.level;
  bool get didLevelUp => _didLevelUp;
  int? get milestone => _milestone;
  int get xpToday => _getXpToday();
  int? get lastXpGain => _lastXpGain;
  String? get lastXpLabel => _lastXpLabel;

  int? _lastXpGain;
  String? _lastXpLabel;

  // Sound
  bool get soundEnabled => _storage.soundEnabled;
  void toggleSound() {
    _storage.soundEnabled = !soundEnabled;
    notifyListeners();
  }

  int get xpForCurrentLevel => _xpForLevel(level);
  int get xpForNextLevel => _xpForLevel(level + 1);
  double get levelProgress {
    final current = xp - xpForCurrentLevel;
    final needed = xpForNextLevel - xpForCurrentLevel;
    if (needed <= 0) return 1.0;
    return (current / needed).clamp(0.0, 1.0);
  }

  static int _xpForLevel(int lvl) => ((lvl - 1) * (lvl - 1) * 50);
  static int xpForLevelPublic(int lvl) => _xpForLevel(lvl);

  static const List<String> levelTitles = [
    'Newbie',        // 1
    'Beginner',      // 2
    'Apprentice',    // 3
    'Regular',       // 4
    'Dedicated',     // 5
    'Committed',     // 6
    'Expert',        // 7
    'Master',        // 8
    'Champion',      // 9
    'Legend',         // 10
    'Mythic',        // 11
    'Immortal',      // 12
    'Transcendent',  // 13
    'Cosmic',        // 14
    'Divine',        // 15
  ];

  static const List<String> levelEmojis = [
    '🥚', '🐣', '🐥', '🐤', '🦅',
    '⭐', '🌟', '💫', '🏆', '👑',
    '🔮', '⚡', '🌈', '☄️', '🌌',
  ];

  String get levelTitle {
    final idx = (level - 1).clamp(0, levelTitles.length - 1);
    return levelTitles[idx];
  }

  String get levelEmoji {
    final idx = (level - 1).clamp(0, levelEmojis.length - 1);
    return levelEmojis[idx];
  }

  int _getXpToday() {
    final today = _dayKey(DateTime.now());
    if (_storage.lastXpDay != today) return 0;
    return _storage.xpToday;
  }

  static String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  void addXp(int amount, {String? label}) {
    _storage.xp = xp + amount;
    _lastXpGain = amount;
    _lastXpLabel = label;
    // Track daily XP
    final today = _dayKey(DateTime.now());
    if (_storage.lastXpDay != today) {
      _storage.lastXpDay = today;
      _storage.xpToday = amount;
    } else {
      _storage.xpToday = _storage.xpToday + amount;
    }
    // Check level up
    while (xp >= xpForNextLevel && level < 99) {
      _storage.level = level + 1;
      _didLevelUp = true;
    }
    notifyListeners();
  }

  void _addXp(int amount, {String? label}) => addXp(amount, label: label);

  /// Award daily login bonus (10 XP, once per day)
  bool checkDailyLoginBonus() {
    final today = _dayKey(DateTime.now());
    if (_storage.lastLoginDay == today) return false;
    _storage.lastLoginDay = today;
    addXp(10, label: 'dailyBonus');
    return true;
  }

  void clearLevelUp() {
    _didLevelUp = false;
  }

  void clearMilestone() {
    _milestone = null;
  }

  void clearLastUnlocked() {
    _lastUnlocked = null;
  }

  void _loadAchievements() {
    final savedData = _storage.achievementsData;
    _achievements = Achievement.all.map((template) {
      final saved = savedData[template.type.index.toString()];
      if (saved != null) {
        return Achievement.fromJson(
          Map<String, dynamic>.from(saved as Map),
          template,
        );
      }
      return template;
    }).toList();
  }

  void _saveAchievements() {
    final data = <String, dynamic>{};
    for (final a in _achievements) {
      if (a.isUnlocked) {
        data[a.type.index.toString()] = a.toJson();
      }
    }
    _storage.achievementsData = data;
  }

  static const Map<AchievementType, int> _achievementXp = {
    AchievementType.firstTap: 5,
    AchievementType.first100: 20,
    AchievementType.first1000: 50,
    AchievementType.first10000: 100,
    AchievementType.streak3: 15,
    AchievementType.streak7: 30,
    AchievementType.streak14: 60,
    AchievementType.streak30: 120,
    AchievementType.streak100: 300,
    AchievementType.goalFirst: 20,
    AchievementType.goal10: 50,
    AchievementType.goal50: 150,
    AchievementType.counter5: 25,
    AchievementType.counter10: 50,
    AchievementType.nightOwl: 15,
    AchievementType.earlyBird: 15,
    AchievementType.weekendWarrior: 15,
  };

  bool _tryUnlock(AchievementType type) {
    final index = _achievements.indexWhere((a) => a.type == type);
    if (index == -1 || _achievements[index].isUnlocked) return false;
    _achievements[index] = _achievements[index].unlock();
    _lastUnlocked = _achievements[index];
    _saveAchievements();
    // Award XP for unlocking achievement
    final bonus = _achievementXp[type] ?? 10;
    addXp(bonus, label: 'achievement');
    notifyListeners();
    return true;
  }

  void recordTap() {
    _storage.totalTaps = totalTaps + 1;
    _recordDayActive();
    _addXp(1, label: 'tap');

    final taps = totalTaps;
    if (taps >= 1) _tryUnlock(AchievementType.firstTap);
    if (taps >= 100) _tryUnlock(AchievementType.first100);
    if (taps >= 1000) _tryUnlock(AchievementType.first1000);
    if (taps >= 10000) _tryUnlock(AchievementType.first10000);

    // Time-based
    final hour = DateTime.now().hour;
    if (hour >= 0 && hour < 5) _tryUnlock(AchievementType.nightOwl);
    if (hour >= 5 && hour < 7) _tryUnlock(AchievementType.earlyBird);
    if (DateTime.now().weekday >= 6) _tryUnlock(AchievementType.weekendWarrior);
  }

  void checkCounterMilestone(int counterValue) {
    const milestones = [50, 100, 500, 1000, 5000, 10000];
    if (milestones.contains(counterValue)) {
      _milestone = counterValue;
      _addXp(counterValue ~/ 10, label: 'milestone');
      notifyListeners();
    }
  }

  void checkStreaks(List<Counter> counters) {
    int maxStreak = 0;
    for (final c in counters) {
      if (c.currentStreak > maxStreak) maxStreak = c.currentStreak;
    }
    if (maxStreak >= 3) _tryUnlock(AchievementType.streak3);
    if (maxStreak >= 7) _tryUnlock(AchievementType.streak7);
    if (maxStreak >= 14) _tryUnlock(AchievementType.streak14);
    if (maxStreak >= 30) _tryUnlock(AchievementType.streak30);
    if (maxStreak >= 100) _tryUnlock(AchievementType.streak100);
  }

  void checkCounterCount(int count) {
    if (count >= 5) _tryUnlock(AchievementType.counter5);
    if (count >= 10) _tryUnlock(AchievementType.counter10);
  }

  void recordGoalCompleted() {
    _storage.goalsCompleted = goalsCompleted + 1;
    _addXp(25, label: 'goal');
    final goals = goalsCompleted;
    if (goals >= 1) _tryUnlock(AchievementType.goalFirst);
    if (goals >= 10) _tryUnlock(AchievementType.goal10);
    if (goals >= 50) _tryUnlock(AchievementType.goal50);
  }

  /// Award XP when a Twin Friends challenge is won
  void recordChallengeWon() {
    addXp(100, label: 'challengeWon');
  }

  /// Award XP when a Twin Friends challenge is completed (participant)
  void recordChallengeCompleted() {
    addXp(40, label: 'challengeCompleted');
  }

  void clearLastXpGain() {
    _lastXpGain = null;
    _lastXpLabel = null;
  }

  void _recordDayActive() {
    final today = DateTime.now();
    final key = '${today.year}-${today.month}-${today.day}';
    final lastDay = _storage.lastActiveDay;
    if (lastDay != key) {
      _storage.lastActiveDay = key;
      _storage.daysActive = daysActive + 1;
    }
  }
}
