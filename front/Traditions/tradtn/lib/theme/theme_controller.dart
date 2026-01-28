import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ThemeController {
  static const _key = 'theme_mode';

  ThemeController() : mode = ValueNotifier<ThemeMode>(ThemeMode.dark);

  final ValueNotifier<ThemeMode> mode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null) {
      mode.value = _parse(saved);
      return;
    }

    try {
      final remote = await ApiService.fetchThemePreference();
      if (remote != null) {
        mode.value = _parse(remote);
        await prefs.setString(_key, _serialize(mode.value));
      }
    } catch (_) {
      // If backend is unavailable, keep the default in-memory mode.
    }
  }

  Future<void> setMode(ThemeMode value) async {
    mode.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _serialize(value));
    await ApiService.updateThemePreference(_serialize(value));
  }

  Future<void> toggle() async {
    final next =
        mode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setMode(next);
  }

  ThemeMode _parse(String value) {
    switch (value.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      case 'dark':
      default:
        return ThemeMode.dark;
    }
  }

  String _serialize(ThemeMode value) {
    switch (value) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.dark:
      default:
        return 'dark';
    }
  }
}
