import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;

  SettingsProvider(this._storage);

  bool get isDarkMode => _storage.isDarkMode;
  String get locale => _storage.locale;
  String get userName => _storage.userName;
  bool get hasUserName => _storage.userName.isNotEmpty;

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleDarkMode() {
    _storage.isDarkMode = !isDarkMode;
    notifyListeners();
  }

  void setLocale(String newLocale) {
    _storage.locale = newLocale;
    notifyListeners();
  }

  void setUserName(String name) {
    _storage.userName = name.trim();
    notifyListeners();
  }
}
