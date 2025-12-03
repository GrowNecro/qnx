import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme manager for app-wide theme state
class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  
  ThemeMode _themeMode = ThemeMode.dark;
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeManager() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 2; // default dark
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  Future<void> toggleTheme() async {
    await setThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
  }

  /// Light theme data
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.grey[100],
    primaryColor: Colors.orange,
    colorScheme: ColorScheme.light(
      primary: Colors.orange,
      secondary: Colors.orangeAccent,
      surface: Colors.white,
      onSurface: Colors.black87,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black87,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Colors.orange,
      thumbColor: Colors.orange,
      inactiveTrackColor: Colors.grey,
    ),
  );

  /// Dark theme data
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    primaryColor: Colors.orange,
    colorScheme: ColorScheme.dark(
      primary: Colors.orange,
      secondary: Colors.orangeAccent,
      surface: Colors.grey[900]!,
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Colors.orange,
      thumbColor: Colors.orange,
      inactiveTrackColor: Colors.grey,
    ),
  );
}
