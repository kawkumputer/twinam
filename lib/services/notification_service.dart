import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Top-level handler required by flutter_local_notifications for background isolate.
@pragma('vm:entry-point')
void _notificationBackgroundHandler(NotificationResponse response) {
  // Cannot navigate from background isolate — payload handled on next launch.
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Global navigator key — pass to MaterialApp.navigatorKey.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Payload stored when the navigator is not yet ready or app was cold-started.
  String? _pendingPayload;
  String? get pendingPayload => _pendingPayload;

  /// Called by DashboardScreen after first frame to consume a pending payload.
  void handlePendingPayload() {
    if (_pendingPayload == null) return;
    final payload = _pendingPayload!;
    _pendingPayload = null;
    final nav = navigatorKey.currentState;
    if (nav != null) _handlePayload(payload, nav);
  }

  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    final nav = navigatorKey.currentState;
    if (nav == null) {
      _pendingPayload = payload;
      debugPrint('[Notif] Nav not ready, queuing payload: $payload');
      return;
    }
    _handlePayload(payload, nav);
  }

  void _handlePayload(String payload, NavigatorState nav) {
    debugPrint('[Notif] Deep-link: $payload');
    if (payload.startsWith('counter:')) {
      final counterId = payload.substring('counter:'.length);
      nav.pushNamed('/counter', arguments: counterId);
    } else if (payload == 'tasks') {
      nav.pushNamed('/tasks');
    }
    // 'dashboard' → app is already open, no navigation needed
  }

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

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _notificationBackgroundHandler,
    );
    _initialized = true;
    debugPrint('[Notif] Plugin initialized');

    // Handle cold-start: app opened by tapping a notification
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      _pendingPayload = launchDetails?.notificationResponse?.payload;
      debugPrint('[Notif] Cold-start payload: $_pendingPayload');
    }
  }

  Future<bool> requestPermission() async {
    if (!kIsWeb && Platform.isAndroid) {
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
    String? payload,
  }) async {
    try {
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
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('[Notif] Scheduled daily reminder id=$id at $hour:$minute');
    } catch (e) {
      debugPrint('[Notif] Failed to schedule daily reminder $id: $e');
    }
  }

  Future<void> cancelReminder(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (e) {
      debugPrint('[Notif] Failed to cancel reminder $id: $e');
    }
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
    required Function(String) translate,
  }) async {
    try {
      final id = 9991; // Fixed ID for evening check
      await cancelReminder(id); // Cancel previous if exists

      final (title, body) = _getEveningMessage(dailyScore, translate);

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
    } catch (e) {
      debugPrint('[Twin] Failed to schedule evening check: $e');
    }
  }

  Future<void> scheduleTwinMorningMotivation({
    required int bestStreak,
    required int totalHabits,
    required Function(String) translate,
  }) async {
    try {
      final id = 9992; // Fixed ID for morning motivation
      await cancelReminder(id);

      final (title, body) = _getMorningMessage(bestStreak, totalHabits, translate);

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
    } catch (e) {
      debugPrint('[Twin] Failed to schedule morning motivation: $e');
    }
  }

  Future<void> scheduleTwinInactivityWarning({
    required int daysInactive,
    required Function(String) translate,
  }) async {
    if (daysInactive < 3) return;

    try {
      final id = 9993; // Fixed ID for inactivity warning
      await cancelReminder(id);

      final (title, body) = _getInactivityMessage(daysInactive, translate);

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
    } catch (e) {
      debugPrint('[Twin] Failed to schedule inactivity warning: $e');
    }
  }

  (String, String) _getEveningMessage(double score, Function(String) translate) {
    if (score >= 1.0) {
      return ('🌟 ${translate('notifPerfectDay')}', translate('notifPerfectDayBody'));
    }
    if (score >= 0.8) {
      return ('💪 ${translate('notifAlmostThere')}', translate('notifAlmostThereBody'));
    }
    if (score >= 0.6) {
      return ('👍 ${translate('notifGoodProgress')}', translate('notifGoodProgressBody'));
    }
    if (score >= 0.4) {
      return ('💭 ${translate('notifHalfwayThere')}', translate('notifHalfwayThereBody'));
    }
    if (score >= 0.2) {
      return ('😔 ${translate('notifToughDay')}', translate('notifToughDayBody'));
    }
    return ('😢 ${translate('notifTwinNeedsYou')}', translate('notifTwinNeedsYouBody'));
  }

  (String, String) _getMorningMessage(int bestStreak, int totalHabits, Function(String) translate) {
    if (bestStreak >= 7) {
      return ('🔥 ${translate('notifWeekWarrior')}', translate('notifWeekWarriorBody'));
    }
    if (bestStreak >= 3) {
      return ('⚡ ${translate('notifOnARoll')}', translate('notifOnARollBody'));
    }
    if (bestStreak >= 1) {
      return ('🌅 ${translate('notifFreshStart')}', translate('notifFreshStartBody'));
    }
    if (totalHabits == 0) {
      return ('🌱 ${translate('notifBeginToday')}', translate('notifBeginTodayBody'));
    }
    return ('☀️ ${translate('notifNewDay')}', translate('notifNewDayBody'));
  }

  (String, String) _getInactivityMessage(int daysInactive, Function(String) translate) {
    if (daysInactive == 3) {
      return ('😢 ${translate('notifTwinMissesYou')}', translate('notifTwinMissesYouBody'));
    }
    if (daysInactive == 7) {
      return ('😡 ${translate('notifTwinIsAngry')}', translate('notifTwinIsAngryBody'));
    }
    return ('😤 ${translate('notifTwinIsFurious')}', translate('notifTwinIsFuriousBody'));
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
    int reminderMinutesBefore = 60,
  }) async {
    final notificationId = taskId.hashCode.abs() % 100000 + 10000;
    
    // Schedule notification based on custom reminder time
    final reminderTime = deadline.subtract(Duration(minutes: reminderMinutesBefore));
    
    // Don't schedule if reminder time is in the past
    if (reminderTime.isBefore(DateTime.now())) {
      debugPrint('[Task] Skipping past reminder for: $title');
      return;
    }

    final priorityEmoji = _getPriorityEmoji(priority);
    final timeLeft = _formatTimeUntilDeadline(deadline);
    final reminderText = _formatReminderTime(reminderMinutesBefore);

    await _plugin.zonedSchedule(
      notificationId,
      '$priorityEmoji Task Reminder',
      '$title - Due in $reminderText ($timeLeft)',
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
      payload: 'tasks',
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

  int _deadlineAlarmId(String taskId) =>
      taskId.hashCode.abs() % 100000 + 20000;

  Future<void> scheduleDeadlineAlarm({
    required String taskId,
    required String title,
    required int priority,
    required DateTime deadline,
  }) async {
    if (deadline.isBefore(DateTime.now())) {
      debugPrint('[Task] Skipping past deadline alarm for: $title');
      return;
    }

    final id = _deadlineAlarmId(taskId);
    final priorityEmoji = _getPriorityEmoji(priority);

    try {
      await _plugin.zonedSchedule(
        id,
        '$priorityEmoji $title',
        '⏰ Échéance atteinte !',
        _toTZDateTime(deadline),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'task_deadline_v1',
            'Task Deadline Alarm',
            channelDescription: 'Alarm when task deadline is reached',
            importance: Importance.max,
            priority: Priority.max,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
            visibility: NotificationVisibility.public,
            playSound: true,
            enableVibration: true,
            vibrationPattern:
                Int64List.fromList([0, 500, 300, 500, 300, 800]),
            icon: '@mipmap/ic_launcher',
            color: _getTaskPriorityColor(priority),
          ),
          iOS: const DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentSound: true,
            presentBadge: true,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
        payload: 'tasks',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('[Task] Deadline alarm scheduled for: $title at $deadline');
    } catch (e) {
      debugPrint('[Task] Failed to schedule deadline alarm: $e');
    }
  }

  Future<void> cancelDeadlineAlarm(String taskId) async {
    await _plugin.cancel(_deadlineAlarmId(taskId));
    debugPrint('[Task] Deadline alarm cancelled for: $taskId');
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

  String _formatReminderTime(int minutes) {
    if (minutes >= 1440) {
      final days = minutes ~/ 1440;
      return '$days day${days > 1 ? 's' : ''}';
    }
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      return '$hours hour${hours > 1 ? 's' : ''}';
    }
    return '$minutes minute${minutes > 1 ? 's' : ''}';
  }

  tz.TZDateTime _toTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }
}
