import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeKey = 'crispr_theme_mode';

enum AppThemePreference { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  ThemeProvider();

  AppThemePreference _preference = AppThemePreference.system;
  bool _ready = false;

  AppThemePreference get preference => _preference;
  bool get isReady => _ready;

  ThemeMode get themeMode => switch (_preference) {
        AppThemePreference.light => ThemeMode.light,
        AppThemePreference.dark => ThemeMode.dark,
        AppThemePreference.system => ThemeMode.system,
      };

  String get apiValue => _preference.name;

  Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_themeKey);
    _preference = _parse(stored);
    _ready = true;
    notifyListeners();
  }

  Future<void> setPreference(AppThemePreference value, {bool persist = true}) async {
    if (_preference == value) return;
    _preference = value;
    notifyListeners();
    if (persist) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, value.name);
    }
  }

  void applyFromServer(String? themeMode) {
    final parsed = _parse(themeMode);
    if (parsed != _preference) {
      _preference = parsed;
      notifyListeners();
      SharedPreferences.getInstance().then(
        (prefs) => prefs.setString(_themeKey, parsed.name),
      );
    }
  }

  AppThemePreference _parse(String? raw) {
    switch (raw) {
      case 'light':
        return AppThemePreference.light;
      case 'dark':
        return AppThemePreference.dark;
      default:
        return AppThemePreference.system;
    }
  }
}
