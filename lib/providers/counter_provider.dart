import 'package:flutter/material.dart';
import '../models/counter.dart';
import '../services/storage_service.dart';

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
    counter.increment();
    await _storage.saveCounter(counter);
    notifyListeners();
  }

  Future<void> decrementCounter(String id) async {
    final counter = _counters.firstWhere((c) => c.id == id);
    counter.decrement();
    await _storage.saveCounter(counter);
    notifyListeners();
  }

  Future<void> resetCounter(String id) async {
    final counter = _counters.firstWhere((c) => c.id == id);
    counter.resetValue();
    await _storage.saveCounter(counter);
    notifyListeners();
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
