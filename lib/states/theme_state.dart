import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tija/constants/app_preference.dart';

class ThemeState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkTheme => _themeMode == ThemeMode.dark;
  String get mapDarkTheme => AppPreference.appDarkTheme;
  String get mapLightTheme => AppPreference.appLightTheme;
  bool get isWhiteThemeStyle => !isDarkTheme;

  /// Loads the persisted theme choice from SharedPreferences.
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppPreference.themeMode);
    _themeMode = saved == AppPreference.appDarkTheme
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  /// Toggles between light and dark and persists the choice.
  Future<void> toggleTheme() async {
    _themeMode = isDarkTheme ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppPreference.themeMode,
      isDarkTheme ? AppPreference.appDarkTheme : AppPreference.appLightTheme,
    );
    notifyListeners();
  }
}
