import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/counter.dart';

class StorageService {
  static const String _countersBox = 'counters';
  static const String _settingsBox = 'settings';

  late Box<String> _counters;
  late Box<dynamic> _settings;

  Future<void> init() async {
    await Hive.initFlutter();
    _counters = await Hive.openBox<String>(_countersBox);
    _settings = await Hive.openBox<dynamic>(_settingsBox);
  }

  // Counters
  List<Counter> getAllCounters() {
    final order = counterOrder;
    final allCounters = _counters.values.map((json) {
      return Counter.fromJson(
        Map<String, dynamic>.from(jsonDecode(json) as Map),
      );
    }).toList();

    if (order.isNotEmpty) {
      allCounters.sort((a, b) {
        final ai = order.indexOf(a.id);
        final bi = order.indexOf(b.id);
        if (ai == -1 && bi == -1) return 0;
        if (ai == -1) return 1;
        if (bi == -1) return -1;
        return ai.compareTo(bi);
      });
    }
    return allCounters;
  }

  Future<void> saveCounter(Counter counter) async {
    await _counters.put(counter.id, jsonEncode(counter.toJson()));
  }

  Future<void> deleteCounter(String id) async {
    await _counters.delete(id);
  }

  // Settings
  bool get isDarkMode => _settings.get('isDarkMode', defaultValue: false) as bool;
  set isDarkMode(bool value) => _settings.put('isDarkMode', value);

  String get locale => _settings.get('locale', defaultValue: 'en') as String;
  set locale(String value) => _settings.put('locale', value);

  String get userName => _settings.get('userName', defaultValue: '') as String;
  set userName(String value) => _settings.put('userName', value);

  // User stats
  int get totalTaps => _settings.get('totalTaps', defaultValue: 0) as int;
  set totalTaps(int value) => _settings.put('totalTaps', value);

  int get daysActive => _settings.get('daysActive', defaultValue: 0) as int;
  set daysActive(int value) => _settings.put('daysActive', value);

  int get goalsCompleted => _settings.get('goalsCompleted', defaultValue: 0) as int;
  set goalsCompleted(int value) => _settings.put('goalsCompleted', value);

  String get lastActiveDay => _settings.get('lastActiveDay', defaultValue: '') as String;
  set lastActiveDay(String value) => _settings.put('lastActiveDay', value);

  // XP & Level
  int get xp => _settings.get('xp', defaultValue: 0) as int;
  set xp(int value) => _settings.put('xp', value);

  int get level => _settings.get('level', defaultValue: 1) as int;
  set level(int value) => _settings.put('level', value);

  // Sound
  bool get soundEnabled => _settings.get('soundEnabled', defaultValue: true) as bool;
  set soundEnabled(bool value) => _settings.put('soundEnabled', value);

  // Achievements
  Map<String, dynamic> get achievementsData {
    final raw = _settings.get('achievements');
    if (raw == null) return {};
    return Map<String, dynamic>.from(jsonDecode(raw as String) as Map);
  }

  set achievementsData(Map<String, dynamic> value) {
    _settings.put('achievements', jsonEncode(value));
  }

  // Counter order
  List<String> get counterOrder {
    final raw = _settings.get('counterOrder');
    if (raw == null) return [];
    return List<String>.from(jsonDecode(raw as String) as List);
  }

  set counterOrder(List<String> value) {
    _settings.put('counterOrder', jsonEncode(value));
  }
}
