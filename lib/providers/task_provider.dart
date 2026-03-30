import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class TaskProvider with ChangeNotifier {
  final StorageService _storage;
  List<Task> _tasks = [];
  bool _isLoading = false;

  TaskProvider(this._storage) {
    _loadTasks();
  }

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;

  List<Task> get todoTasks => _tasks.where((t) => t.status == TaskStatus.todo).toList();
  List<Task> get inProgressTasks => _tasks.where((t) => t.status == TaskStatus.inProgress).toList();
  List<Task> get doneTasks => _tasks.where((t) => t.status == TaskStatus.done).toList();
  
  List<Task> get overdueTasks => _tasks.where((t) => t.isOverdue).toList();
  List<Task> get todayTasks => _tasks.where((t) => t.isDueToday).toList();
  List<Task> get upcomingTasks => _tasks.where((t) => t.isDueSoon).toList();

  int get overdueCount => overdueTasks.length;
  int get todayCount => todayTasks.length;
  int get completedTodayCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _tasks.where((t) {
      if (t.completedAt == null) return false;
      final completedDay = DateTime(
        t.completedAt!.year,
        t.completedAt!.month,
        t.completedAt!.day,
      );
      return completedDay.isAtSameMomentAs(today);
    }).length;
  }

  Future<void> _loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = _storage.getTasksData();
      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data);
        _tasks = jsonList.map((json) => Task.fromJson(json)).toList();
        _sortTasks();
      }
    } catch (e) {
      debugPrint('[TaskProvider] Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveTasks() async {
    try {
      final jsonList = _tasks.map((t) => t.toJson()).toList();
      await _storage.saveTasksData(jsonEncode(jsonList));
    } catch (e) {
      debugPrint('[TaskProvider] Error saving tasks: $e');
    }
  }

  void _sortTasks() {
    _tasks.sort((a, b) {
      // Done tasks go to bottom
      if (a.status == TaskStatus.done && b.status != TaskStatus.done) return 1;
      if (a.status != TaskStatus.done && b.status == TaskStatus.done) return -1;
      
      // Overdue tasks on top
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;
      
      // Sort by priority
      if (a.priority != b.priority) {
        return b.priority.index.compareTo(a.priority.index);
      }
      
      // Sort by deadline
      return a.deadline.compareTo(b.deadline);
    });
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    _sortTasks();
    await _saveTasks();
    
    // Schedule notification if task is not done
    if (task.status != TaskStatus.done) {
      await _scheduleTaskNotification(task);
    }
    
    notifyListeners();
    debugPrint('[TaskProvider] Task added: ${task.title}');
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      _sortTasks();
      await _saveTasks();
      
      // Cancel old notification and reschedule if needed
      await NotificationService().cancelTaskReminder(updatedTask.id);
      if (updatedTask.status != TaskStatus.done) {
        await _scheduleTaskNotification(updatedTask);
      }
      
      notifyListeners();
      debugPrint('[TaskProvider] Task updated: ${updatedTask.title}');
    }
  }

  Future<void> deleteTask(String taskId) async {
    await NotificationService().cancelTaskReminder(taskId);
    _tasks.removeWhere((t) => t.id == taskId);
    await _saveTasks();
    notifyListeners();
    debugPrint('[TaskProvider] Task deleted: $taskId');
  }

  Future<void> markTaskAsDone(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].markAsDone();
      await NotificationService().cancelTaskReminder(taskId);
      _sortTasks();
      await _saveTasks();
      notifyListeners();
      debugPrint('[TaskProvider] Task marked as done: ${_tasks[index].title}');
    }
  }

  Future<void> markTaskAsInProgress(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].markAsInProgress();
      _sortTasks();
      await _saveTasks();
      notifyListeners();
      debugPrint('[TaskProvider] Task marked as in progress: ${_tasks[index].title}');
    }
  }

  Future<void> markTaskAsTodo(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].markAsTodo();
      _sortTasks();
      await _saveTasks();
      notifyListeners();
      debugPrint('[TaskProvider] Task marked as todo: ${_tasks[index].title}');
    }
  }

  Task? getTaskById(String taskId) {
    try {
      return _tasks.firstWhere((t) => t.id == taskId);
    } catch (e) {
      return null;
    }
  }

  List<Task> getTasksByStatus(TaskStatus status) {
    return _tasks.where((t) => t.status == status).toList();
  }

  List<Task> getTasksByPriority(TaskPriority priority) {
    return _tasks.where((t) => t.priority == priority).toList();
  }

  List<Task> getTasksForDate(DateTime date) {
    final targetDay = DateTime(date.year, date.month, date.day);
    return _tasks.where((t) {
      final taskDay = DateTime(t.deadline.year, t.deadline.month, t.deadline.day);
      return taskDay.isAtSameMomentAs(targetDay);
    }).toList();
  }

  Future<void> clearCompletedTasks() async {
    _tasks.removeWhere((t) => t.status == TaskStatus.done);
    await _saveTasks();
    notifyListeners();
    debugPrint('[TaskProvider] Completed tasks cleared');
  }

  Future<void> _scheduleTaskNotification(Task task) async {
    try {
      await NotificationService().scheduleTaskReminder(
        taskId: task.id,
        title: task.title,
        description: task.description,
        deadline: task.deadline,
        priority: task.priority.index,
      );
    } catch (e) {
      debugPrint('[TaskProvider] Error scheduling notification: $e');
    }
  }
}
