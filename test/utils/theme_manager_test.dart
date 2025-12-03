import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qnx/utils/theme_manager.dart';

void main() {
  group('ThemeManager', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should default to dark theme', () async {
      SharedPreferences.setMockInitialValues({});
      final manager = ThemeManager();
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(manager.themeMode, equals(ThemeMode.dark));
      expect(manager.isDarkMode, isTrue);
    });

    test('should load saved theme from preferences', () async {
      // ThemeMode.light has index 1
      SharedPreferences.setMockInitialValues({'app_theme_mode': 1});
      final manager = ThemeManager();
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(manager.themeMode, equals(ThemeMode.light));
      expect(manager.isDarkMode, isFalse);
    });

    group('setThemeMode', () {
      test('should change theme to light', () async {
        SharedPreferences.setMockInitialValues({});
        final manager = ThemeManager();
        await Future.delayed(const Duration(milliseconds: 100));

        await manager.setThemeMode(ThemeMode.light);

        expect(manager.themeMode, equals(ThemeMode.light));
        expect(manager.isDarkMode, isFalse);
      });

      test('should change theme to dark', () async {
        SharedPreferences.setMockInitialValues({'app_theme_mode': 1});
        final manager = ThemeManager();
        await Future.delayed(const Duration(milliseconds: 100));

        await manager.setThemeMode(ThemeMode.dark);

        expect(manager.themeMode, equals(ThemeMode.dark));
        expect(manager.isDarkMode, isTrue);
      });

      test('should save theme to preferences', () async {
        SharedPreferences.setMockInitialValues({});
        final manager = ThemeManager();
        await Future.delayed(const Duration(milliseconds: 100));

        await manager.setThemeMode(ThemeMode.light);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt('app_theme_mode'), equals(ThemeMode.light.index));
      });

      test('should notify listeners on theme change', () async {
        SharedPreferences.setMockInitialValues({});
        final manager = ThemeManager();
        await Future.delayed(const Duration(milliseconds: 100));

        int callCount = 0;
        manager.addListener(() => callCount++);

        await manager.setThemeMode(ThemeMode.light);

        expect(callCount, greaterThan(0));
      });
    });

    group('toggleTheme', () {
      test('should toggle from dark to light', () async {
        SharedPreferences.setMockInitialValues({'app_theme_mode': 2}); // dark
        final manager = ThemeManager();
        await Future.delayed(const Duration(milliseconds: 100));

        await manager.toggleTheme();

        expect(manager.themeMode, equals(ThemeMode.light));
      });

      test('should toggle from light to dark', () async {
        SharedPreferences.setMockInitialValues({'app_theme_mode': 1}); // light
        final manager = ThemeManager();
        await Future.delayed(const Duration(milliseconds: 100));

        await manager.toggleTheme();

        expect(manager.themeMode, equals(ThemeMode.dark));
      });
    });

    group('static themes', () {
      test('lightTheme should have correct brightness', () {
        expect(ThemeManager.lightTheme.brightness, equals(Brightness.light));
      });

      test('darkTheme should have correct brightness', () {
        expect(ThemeManager.darkTheme.brightness, equals(Brightness.dark));
      });

      test('lightTheme should have orange primary color', () {
        expect(ThemeManager.lightTheme.primaryColor, equals(Colors.orange));
      });

      test('darkTheme should have orange primary color', () {
        expect(ThemeManager.darkTheme.primaryColor, equals(Colors.orange));
      });

      test('lightTheme should use Material 3', () {
        expect(ThemeManager.lightTheme.useMaterial3, isTrue);
      });

      test('darkTheme should use Material 3', () {
        expect(ThemeManager.darkTheme.useMaterial3, isTrue);
      });

      test('lightTheme should have light scaffold background', () {
        expect(ThemeManager.lightTheme.scaffoldBackgroundColor, equals(Colors.grey[100]));
      });

      test('darkTheme should have black scaffold background', () {
        expect(ThemeManager.darkTheme.scaffoldBackgroundColor, equals(Colors.black));
      });
    });
  });
}
