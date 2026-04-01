import 'package:home_widget/home_widget.dart';
import 'package:flutter/material.dart';
import '../models/counter.dart';
import '../models/task.dart';

class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  // Update widget with counter data
  Future<void> updateCounterWidget({
    required List<Counter> counters,
    required double score,
    required int level,
    required String levelTitle,
  }) async {
    try {
      // Calculate stats
      final totalCounters = counters.length;
      final goalsReached = counters.where((c) => c.goalReached).length;
      final todayProgress = (score * 100).toInt();
      
      // Get top 3 counters
      final sortedCounters = List<Counter>.from(counters)
        ..sort((a, b) => b.value.compareTo(a.value));
      final topCounters = sortedCounters.take(3).toList();

      // Save data to widget
      await HomeWidget.saveWidgetData<int>('totalCounters', totalCounters);
      await HomeWidget.saveWidgetData<int>('goalsReached', goalsReached);
      await HomeWidget.saveWidgetData<int>('todayProgress', todayProgress);
      await HomeWidget.saveWidgetData<int>('level', level);
      await HomeWidget.saveWidgetData<String>('levelTitle', levelTitle);
      
      // Save top counters
      for (int i = 0; i < topCounters.length; i++) {
        await HomeWidget.saveWidgetData<String>('counter${i}_name', topCounters[i].name);
        await HomeWidget.saveWidgetData<int>('counter${i}_value', topCounters[i].value);
        await HomeWidget.saveWidgetData<int>('counter${i}_goal', topCounters[i].goal ?? 0);
      }

      // Update widget
      await HomeWidget.updateWidget(
        androidName: 'TwinAmWidgetProvider',
        iOSName: 'TwinAmWidget',
      );
      
      debugPrint('[WidgetService] Widget updated successfully');
    } catch (e) {
      debugPrint('[WidgetService] Error updating widget: $e');
    }
  }

  // Update widget with task data
  Future<void> updateTaskWidget({
    required List<Task> tasks,
    required int overdueCount,
    required int todayCount,
    required int completedTodayCount,
  }) async {
    try {
      // Get urgent tasks (overdue + today)
      final urgentTasks = <Task>{
        ...tasks.where((t) => t.isOverdue),
        ...tasks.where((t) => t.isDueToday),
      }.take(5).toList();

      // Save data to widget
      await HomeWidget.saveWidgetData<int>('overdueCount', overdueCount);
      await HomeWidget.saveWidgetData<int>('todayCount', todayCount);
      await HomeWidget.saveWidgetData<int>('completedTodayCount', completedTodayCount);
      
      // Save urgent tasks
      for (int i = 0; i < urgentTasks.length; i++) {
        await HomeWidget.saveWidgetData<String>('task${i}_title', urgentTasks[i].title);
        await HomeWidget.saveWidgetData<bool>('task${i}_overdue', urgentTasks[i].isOverdue);
        await HomeWidget.saveWidgetData<String>('task${i}_priority', urgentTasks[i].priority.name);
      }

      // Update widget
      await HomeWidget.updateWidget(
        androidName: 'TwinAmTaskWidgetProvider',
        iOSName: 'TwinAmTaskWidget',
      );
      
      debugPrint('[WidgetService] Task widget updated successfully');
    } catch (e) {
      debugPrint('[WidgetService] Error updating task widget: $e');
    }
  }

  // Update Twin status widget
  Future<void> updateTwinWidget({
    required String twinState,
    required String message,
    required double score,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('twinState', twinState);
      await HomeWidget.saveWidgetData<String>('twinMessage', message);
      await HomeWidget.saveWidgetData<int>('twinScore', (score * 100).toInt());

      // Update widget
      await HomeWidget.updateWidget(
        androidName: 'TwinAmTwinWidgetProvider',
        iOSName: 'TwinAmTwinWidget',
      );
      
      debugPrint('[WidgetService] Twin widget updated successfully');
    } catch (e) {
      debugPrint('[WidgetService] Error updating twin widget: $e');
    }
  }

  // Initialize widget callbacks
  Future<void> initialize() async {
    try {
      // Register callback for widget interactions
      // iOS uses App Groups, Android doesn't need this
      await HomeWidget.setAppGroupId('group.com.twinam.app');
      
      debugPrint('[WidgetService] Initialized successfully');
    } catch (e) {
      debugPrint('[WidgetService] Error initializing: $e');
    }
  }

  // Handle widget tap actions
  static Future<void> handleWidgetAction(Uri? uri) async {
    if (uri == null) return;
    
    debugPrint('[WidgetService] Widget action: ${uri.toString()}');
    
    // Handle different actions
    // Example: twinam://counter/increment/counter_id
    // Example: twinam://task/complete/task_id
    // Example: twinam://open/dashboard
  }
}
