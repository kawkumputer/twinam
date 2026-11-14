import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;

  SettingsProvider(this._storage);

  String get locale => _storage.locale;
  String get userName => _storage.userName;
  bool get hasUserName => _storage.userName.isNotEmpty;
  bool get onboardingCompleted => _storage.onboardingCompleted;

  ThemeMode get themeMode => ThemeMode.values.firstWhere(
        (m) => m.name == _storage.themeMode,
        orElse: () => ThemeMode.system,
      );

  void setThemeMode(ThemeMode mode) {
    _storage.themeMode = mode.name;
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

  void completeOnboarding() {
    _storage.onboardingCompleted = true;
    notifyListeners();
  }
}
