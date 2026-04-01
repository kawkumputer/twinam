import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/counter.dart';
import 'notification_service.dart';

class TwinNotificationService {
  static final TwinNotificationService _instance = TwinNotificationService._internal();
  factory TwinNotificationService() => _instance;
  TwinNotificationService._internal();

  final NotificationService _notifService = NotificationService();
  Timer? _dailyScheduleTimer;
  DateTime? _lastScheduledDate;

  void init() {
    _notifService.init();
    _startDailyScheduler();
    debugPrint('[TwinNotif] Service initialized');
  }

  void _startDailyScheduler() {
    _dailyScheduleTimer?.cancel();
    _dailyScheduleTimer = Timer.periodic(const Duration(hours: 1), (_) {
      debugPrint('[TwinNotif] Hourly check for notification updates');
    });
  }

  void scheduleNotificationsIfNeeded({
    required List<Counter> counters,
    required int bestStreak,
    required Function(String) translate,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Only schedule once per day
    if (_lastScheduledDate != null && _lastScheduledDate!.isAtSameMomentAs(today)) {
      return;
    }
    _lastScheduledDate = today;

    final dailyScore = _computeDailyScore(counters);
    final daysInactive = _computeDaysInactive(counters);

    // Schedule evening check
    _notifService.scheduleTwinEveningCheck(
      dailyScore: dailyScore,
      translate: translate,
    );

    // Schedule morning motivation
    _notifService.scheduleTwinMorningMotivation(
      bestStreak: bestStreak,
      totalHabits: counters.length,
      translate: translate,
    );

    // Schedule inactivity warning if needed
    _notifService.scheduleTwinInactivityWarning(
      daysInactive: daysInactive,
      translate: translate,
    );

    debugPrint('[TwinNotif] Daily notifications scheduled');
    debugPrint('[TwinNotif] Score: ${(dailyScore * 100).toInt()}%');
    debugPrint('[TwinNotif] Inactive days: $daysInactive');
  }

  double _computeDailyScore(List<Counter> counters) {
    if (counters.isEmpty) return 0;
    final withGoal = counters.where((c) => c.goal != null).toList();
    if (withGoal.isEmpty) {
      final total = counters.fold<int>(0, (sum, c) => sum + c.value);
      return total > 0 ? 1.0 : 0.0;
    }
    final reached = withGoal.where((c) => c.goalReached).length;
    return reached / withGoal.length;
  }

  int _computeDaysInactive(List<Counter> counters) {
    if (counters.isEmpty) return 0;
    
    // Find the most recent activity across all counters
    DateTime? lastActivity;
    
    for (final counter in counters) {
      if (counter.history.isEmpty) continue;
      
      for (final entry in counter.history.reversed) {
        if (!entry.isReset) {
          if (lastActivity == null || entry.date.isAfter(lastActivity)) {
            lastActivity = entry.date;
          }
          break; // Found most recent for this counter
        }
      }
    }
    
    if (lastActivity == null) {
      // No activity ever, check when counters were created
      final oldestCreation = counters
          .map((c) => c.createdAt)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      return DateTime.now().difference(oldestCreation).inDays;
    }
    
    return DateTime.now().difference(lastActivity).inDays;
  }

  void rescheduleAllNotifications({
    required List<Counter> counters,
    required int bestStreak,
    required Function(String) translate,
  }) {
    // Cancel all existing Twin notifications
    _notifService.cancelTwinNotifications();
    
    // Schedule fresh ones
    scheduleNotificationsIfNeeded(
      counters: counters,
      bestStreak: bestStreak,
      translate: translate,
    );
    
    debugPrint('[TwinNotif] All Twin notifications rescheduled');
  }

  void dispose() {
    _dailyScheduleTimer?.cancel();
    debugPrint('[TwinNotif] Service disposed');
  }
}
