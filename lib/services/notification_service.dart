import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    debugPrint('[Notif] Timezone set to: ${tzInfo.identifier}');

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: "Open Twin'Am",
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
    debugPrint('[Notif] Plugin initialized');
  }

  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        debugPrint('[Notif] POST_NOTIFICATIONS permission: $granted');
        final exactAlarm = await android.requestExactAlarmsPermission();
        debugPrint('[Notif] Exact alarm permission: $exactAlarm');
        return granted ?? false;
      }
    }
    return true;
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          channelDescription: 'Daily counter reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    debugPrint('[Notif] Scheduled daily reminder id=$id at $hour:$minute');
    debugPrint('[Notif] Next fire: ${_nextInstanceOfTime(hour, minute)}');
  }

  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  int notificationIdFromCounterId(String counterId) {
    return counterId.hashCode.abs() % 100000;
  }

  // ── Twin Notifications ─────────────────────────────────────────────────────

  Future<void> scheduleTwinEveningCheck({
    required double dailyScore,
  }) async {
    final id = 9991; // Fixed ID for evening check
    await cancelReminder(id); // Cancel previous if exists

    final (title, body) = _getEveningMessage(dailyScore);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(21, 0), // 9 PM
      NotificationDetails(
        android: AndroidNotificationDetails(
          'twin_evening',
          'Twin Evening Check',
          channelDescription: 'Daily evening Twin status check',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: _getTwinColor(dailyScore),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    debugPrint('[Twin] Evening check scheduled (score: ${(dailyScore * 100).toInt()}%)');
  }

  Future<void> scheduleTwinMorningMotivation({
    required int bestStreak,
    required int totalHabits,
  }) async {
    final id = 9992; // Fixed ID for morning motivation
    await cancelReminder(id);

    final (title, body) = _getMorningMessage(bestStreak, totalHabits);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(8, 0), // 8 AM
      NotificationDetails(
        android: AndroidNotificationDetails(
          'twin_morning',
          'Twin Morning Motivation',
          channelDescription: 'Daily morning Twin motivation',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF2196F3),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    debugPrint('[Twin] Morning motivation scheduled (streak: $bestStreak)');
  }

  Future<void> scheduleTwinInactivityWarning({
    required int daysInactive,
  }) async {
    if (daysInactive < 3) return;

    final id = 9993; // Fixed ID for inactivity warning
    await cancelReminder(id);

    final (title, body) = _getInactivityMessage(daysInactive);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(19, 0), // 7 PM
      NotificationDetails(
        android: AndroidNotificationDetails(
          'twin_inactivity',
          'Twin Inactivity Warning',
          channelDescription: 'Inactivity warnings from Twin',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFFF7043),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    debugPrint('[Twin] Inactivity warning scheduled (days: $daysInactive)');
  }

  (String, String) _getEveningMessage(double score) {
    if (score >= 1.0) {
      return ('🌟 Perfect Day!', 'Your Twin is so proud! Every goal crushed today!');
    }
    if (score >= 0.8) {
      return ('💪 Almost There!', 'Your Twin says: "One more push and you\'re unstoppable!"');
    }
    if (score >= 0.6) {
      return ('👍 Good Progress', 'Your Twin: "Keep going, you\'ve got this!"');
    }
    if (score >= 0.4) {
      return ('💭 Halfway There', 'Your Twin: "Every action counts — start now!"');
    }
    if (score >= 0.2) {
      return ('😔 Tough Day?', 'Your Twin: "That\'s okay. One habit done is better than zero."');
    }
    return ('😢 Twin Needs You', 'Your Twin: "I\'m waiting... come back and do just ONE habit!"');
  }

  (String, String) _getMorningMessage(int bestStreak, int totalHabits) {
    if (bestStreak >= 7) {
      return ('🔥 Week Warrior!', "Your Twin: \"Let's keep this fire burning today!\"");
    }
    if (bestStreak >= 3) {
      return ('⚡ On a Roll!', "Your Twin: \"Three days strong! Let's make it four!\"");
    }
    if (bestStreak >= 1) {
      return ('🌅 Fresh Start!', "Your Twin: \"Yesterday was great, today will be better!\"");
    }
    if (totalHabits == 0) {
      return ('🌱 Begin Today', "Your Twin: \"Let's start your journey together!\"");
    }
    return ('☀️ New Day!', "Your Twin: \"Every day is a chance to grow!\"");
  }

  (String, String) _getInactivityMessage(int daysInactive) {
    if (daysInactive == 3) {
      return ('😢 Twin Misses You', 'Your Twin: "Where have you been? I miss our progress!"');
    }
    if (daysInactive == 7) {
      return ('😡 Twin is Angry', 'Your Twin: "Who is this person? You\'re not the one I know!"');
    }
    return ('😤 Twin is Furious', 'Your Twin: "Enough! Open the app NOW and show me you care!"');
  }

  Color _getTwinColor(double score) {
    if (score >= 0.8) return const Color(0xFF4CAF50);
    if (score >= 0.4) return const Color(0xFF2196F3);
    return const Color(0xFFFF7043);
  }

  void cancelTwinNotifications() {
    cancelReminder(9991); // Evening check
    cancelReminder(9992); // Morning motivation
    cancelReminder(9993); // Inactivity warning
  }

  // ── Task Notifications ─────────────────────────────────────────────────────

  Future<void> scheduleTaskReminder({
    required String taskId,
    required String title,
    required String description,
    required DateTime deadline,
    required int priority,
  }) async {
    final notificationId = taskId.hashCode.abs() % 100000 + 10000;
    
    // Schedule 1 hour before deadline
    final reminderTime = deadline.subtract(const Duration(hours: 1));
    
    // Don't schedule if reminder time is in the past
    if (reminderTime.isBefore(DateTime.now())) {
      debugPrint('[Task] Skipping past reminder for: $title');
      return;
    }

    final priorityEmoji = _getPriorityEmoji(priority);
    final timeLeft = _formatTimeUntilDeadline(deadline);

    await _plugin.zonedSchedule(
      notificationId,
      '$priorityEmoji Task Reminder',
      '$title - Due in 1 hour ($timeLeft)',
      _toTZDateTime(reminderTime),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Reminders for upcoming tasks',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: _getTaskPriorityColor(priority),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    
    debugPrint('[Task] Reminder scheduled for: $title at ${reminderTime.toString()}');
  }

  Future<void> cancelTaskReminder(String taskId) async {
    final notificationId = taskId.hashCode.abs() % 100000 + 10000;
    await _plugin.cancel(notificationId);
    debugPrint('[Task] Reminder cancelled for task: $taskId');
  }

  String _getPriorityEmoji(int priority) {
    switch (priority) {
      case 2: // High
        return '🔴';
      case 1: // Medium
        return '🟡';
      case 0: // Low
        return '🟢';
      default:
        return '📋';
    }
  }

  Color _getTaskPriorityColor(int priority) {
    switch (priority) {
      case 2: // High
        return const Color(0xFFFF7043);
      case 1: // Medium
        return const Color(0xFFFF9800);
      case 0: // Low
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF2196F3);
    }
  }

  String _formatTimeUntilDeadline(DateTime deadline) {
    final now = DateTime.now();
    final diff = deadline.difference(now);
    
    if (diff.inDays > 0) {
      return '${diff.inDays}d ${diff.inHours % 24}h';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours}h ${diff.inMinutes % 60}m';
    }
    return '${diff.inMinutes}m';
  }

  tz.TZDateTime _toTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }
}
