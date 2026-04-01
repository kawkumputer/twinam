import 'package:flutter/material.dart';
import '../models/counter.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../services/widget_service.dart';

class CounterProvider extends ChangeNotifier {
  final StorageService _storage;
  List<Counter> _counters = [];

  CounterProvider(this._storage) {
    _loadCounters();
  }

  List<Counter> get counters => _counters;

  void _loadCounters() {
    _counters = _storage.getAllCounters();
    _checkAutoResets();
    notifyListeners();
  }

  void _checkAutoResets() {
    for (final counter in _counters) {
      if (counter.shouldReset()) {
        counter.resetValue();
        _storage.saveCounter(counter);
      }
    }
  }

  Future<void> addCounter(Counter counter) async {
    _counters.add(counter);
    await _storage.saveCounter(counter);
    _saveOrder();
    notifyListeners();
  }

  Future<void> updateCounter(Counter counter) async {
    final index = _counters.indexWhere((c) => c.id == counter.id);
    if (index != -1) {
      _counters[index] = counter;
      await _storage.saveCounter(counter);
      notifyListeners();
    }
  }

  Future<void> deleteCounter(String id) async {
    _counters.removeWhere((c) => c.id == id);
    await _storage.deleteCounter(id);
    _saveOrder();
    notifyListeners();
  }

  Future<void> incrementCounter(String id) async {
    final counter = _counters.firstWhere((c) => c.id == id);
    final wasGoalReached = counter.goalReached;
    counter.increment();
    
    // Play celebration sound if goal just reached
    if (!wasGoalReached && counter.goalReached) {
      AudioService().playCelebration();
    }
    
    await _storage.saveCounter(counter);
    _updateWidgets();
    notifyListeners();
  }

  Future<void> decrementCounter(String id) async {
    final counter = _counters.firstWhere((c) => c.id == id);
    counter.decrement();
    await _storage.saveCounter(counter);
    _updateWidgets();
    notifyListeners();
  }

  Future<void> resetCounter(String id) async {
    final counter = _counters.firstWhere((c) => c.id == id);
    counter.resetValue();
    await _storage.saveCounter(counter);
    _updateWidgets();
    notifyListeners();
  }

  void _updateWidgets() {
    // Calculate score for widget
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    double score = 0.0;
    int totalWithGoals = 0;
    
    for (final counter in _counters) {
      if (counter.goal != null) {
        totalWithGoals++;
        if (counter.goalReached) score += 1.0;
      }
    }
    
    if (totalWithGoals > 0) {
      score = score / totalWithGoals;
    }
    
    // Update widget with current data
    WidgetService().updateCounterWidget(
      counters: _counters,
      score: score,
      level: 1, // Will be updated with actual level from AchievementProvider
      levelTitle: 'Newbie',
    );
  }

  Future<void> reorderCounters(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final counter = _counters.removeAt(oldIndex);
    _counters.insert(newIndex, counter);
    _saveOrder();
    notifyListeners();
  }

  void _saveOrder() {
    _storage.counterOrder = _counters.map((c) => c.id).toList();
  }

  Counter? getCounter(String id) {
    try {
      return _counters.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
