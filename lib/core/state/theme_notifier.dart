import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  static const _prefsKey = 'theme_mode';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  ThemeNotifier() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_prefsKey);
      switch (value) {
        case 'light':
          _mode = ThemeMode.light;
          break;
        case 'dark':
          _mode = ThemeMode.dark;
          break;
        case 'system':
        default:
          _mode = ThemeMode.system;
      }
      notifyListeners();
    } catch (_) {
      // ignore errors, default to system
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _prefsKey,
          mode == ThemeMode.light
              ? 'light'
              : mode == ThemeMode.dark
                  ? 'dark'
                  : 'system');
    } catch (_) {
      // ignore
    }
  }

  Future<void> cycleMode() async {
    // Light -> Dark -> System -> Light
    if (_mode == ThemeMode.light) {
      await setMode(ThemeMode.dark);
    } else if (_mode == ThemeMode.dark) {
      await setMode(ThemeMode.system);
    } else {
      await setMode(ThemeMode.light);
    }
  }
}
