enum ResetFrequency { daily, weekly, monthly, never }

enum GoalDirection { reach, stayBelow }

class Counter {
  final String id;
  String name;
  String emoji;
  int value;
  int? goal;
  GoalDirection goalDirection;
  ResetFrequency resetFrequency;
  int step;
  int colorValue;
  DateTime createdAt;
  DateTime lastResetAt;
  List<CounterEntry> history;
  bool reminderEnabled;
  int reminderHour;
  int reminderMinute;

  Counter({
    required this.id,
    required this.name,
    this.emoji = '🔢',
    this.value = 0,
    this.goal,
    this.goalDirection = GoalDirection.reach,
    this.resetFrequency = ResetFrequency.daily,
    this.step = 1,
    this.colorValue = 0xFF2196F3,
    this.reminderEnabled = false,
    this.reminderHour = 9,
    this.reminderMinute = 0,
    DateTime? createdAt,
    DateTime? lastResetAt,
    List<CounterEntry>? history,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastResetAt = lastResetAt ?? DateTime.now(),
        history = history ?? [];

  double get progress {
    if (goal == null || goal == 0) return 0;
    return (value / goal!).clamp(0.0, 1.0);
  }

  bool get goalReached {
    if (goal == null) return false;
    if (goalDirection == GoalDirection.reach) {
      return value >= goal!;
    } else {
      return value <= goal!;
    }
  }

  bool get goalExceeded {
    if (goal == null) return false;
    if (goalDirection == GoalDirection.stayBelow) {
      return value > goal!;
    }
    return false;
  }

  void increment() {
    value += step;
    _addEntry();
  }

  void decrement() {
    value = (value - step).clamp(0, double.maxFinite.toInt());
    _addEntry();
  }

  void resetValue() {
    if (value > 0) {
      history.add(CounterEntry(
        date: DateTime.now(),
        value: value,
        isReset: true,
      ));
    }
    value = 0;
    lastResetAt = DateTime.now();
  }

  void _addEntry() {
    history.add(CounterEntry(
      date: DateTime.now(),
      value: value,
    ));
  }

  int get currentStreak {
    if (goal == null) return 0;
    final now = DateTime.now();
    int streak = 0;

    // Check if goal is reached today
    if (goalReached) streak = 1;

    // Walk backwards through history to find consecutive days
    final dailyMax = <String, int>{};
    for (final entry in history) {
      if (entry.isReset) continue;
      final key = '${entry.date.year}-${entry.date.month}-${entry.date.day}';
      if (!dailyMax.containsKey(key) || entry.value > dailyMax[key]!) {
        dailyMax[key] = entry.value;
      }
    }

    for (int i = 1; i < 365; i++) {
      final day = now.subtract(Duration(days: i));
      final key = '${day.year}-${day.month}-${day.day}';
      final maxVal = dailyMax[key];
      if (maxVal == null) break;
      final reached = goalDirection == GoalDirection.reach
          ? maxVal >= goal!
          : maxVal <= goal!;
      if (reached) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  bool shouldReset() {
    final now = DateTime.now();
    switch (resetFrequency) {
      case ResetFrequency.daily:
        return now.day != lastResetAt.day ||
            now.month != lastResetAt.month ||
            now.year != lastResetAt.year;
      case ResetFrequency.weekly:
        final diff = now.difference(lastResetAt).inDays;
        return diff >= 7 || now.weekday < lastResetAt.weekday;
      case ResetFrequency.monthly:
        return now.month != lastResetAt.month || now.year != lastResetAt.year;
      case ResetFrequency.never:
        return false;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'value': value,
      'goal': goal,
      'goalDirection': goalDirection.index,
      'resetFrequency': resetFrequency.index,
      'step': step,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
      'lastResetAt': lastResetAt.toIso8601String(),
      'history': history.map((e) => e.toJson()).toList(),
      'reminderEnabled': reminderEnabled,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
    };
  }

  factory Counter.fromJson(Map<String, dynamic> json) {
    return Counter(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String? ?? '🔢',
      value: json['value'] as int? ?? 0,
      goal: json['goal'] as int?,
      goalDirection: GoalDirection.values[json['goalDirection'] as int? ?? 0],
      resetFrequency: ResetFrequency.values[json['resetFrequency'] as int? ?? 0],
      step: json['step'] as int? ?? 1,
      colorValue: json['colorValue'] as int? ?? 0xFF2196F3,
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      reminderHour: json['reminderHour'] as int? ?? 9,
      reminderMinute: json['reminderMinute'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastResetAt: DateTime.parse(json['lastResetAt'] as String),
      history: (json['history'] as List<dynamic>?)
              ?.map((e) => CounterEntry.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }
}

class CounterEntry {
  final DateTime date;
  final int value;
  final bool isReset;

  CounterEntry({
    required this.date,
    required this.value,
    this.isReset = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      'isReset': isReset,
    };
  }

  factory CounterEntry.fromJson(Map<String, dynamic> json) {
    return CounterEntry(
      date: DateTime.parse(json['date'] as String),
      value: json['value'] as int? ?? 0,
      isReset: json['isReset'] as bool? ?? false,
    );
  }
}
