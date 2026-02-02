import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  // ThemeModeNotifier() : super(ThemeMode.system);
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeName = prefs.getString("themeMode");
    state = ThemeMode.values
        .where((element) => element.name == themeModeName)
        .first;
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = themeMode; // All App refreshed

    /// Thememode saved in prefs
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("themeMode", themeMode.name);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);
