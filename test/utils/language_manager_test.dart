import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qnx/utils/language_manager.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LanguageManager', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should initialize with English as default', () async {
      final manager = LanguageManager();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(manager.languageCode, 'en');
      expect(manager.isEnglish, isTrue);
      expect(manager.isIndonesian, isFalse);
    });

    test('should load saved language from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'app_language': 'id'});
      
      final manager = LanguageManager();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(manager.languageCode, 'id');
      expect(manager.isIndonesian, isTrue);
      expect(manager.isEnglish, isFalse);
    });

    test('setEnglish should change locale to English', () async {
      SharedPreferences.setMockInitialValues({});
      final manager = LanguageManager();
      await Future.delayed(const Duration(milliseconds: 100));

      await manager.setIndonesian();
      expect(manager.isIndonesian, isTrue);

      await manager.setEnglish();
      expect(manager.isEnglish, isTrue);
      expect(manager.locale, const Locale('en', 'US'));
    });

    test('setIndonesian should change locale to Indonesian', () async {
      SharedPreferences.setMockInitialValues({});
      final manager = LanguageManager();
      await Future.delayed(const Duration(milliseconds: 100));

      await manager.setIndonesian();

      expect(manager.isIndonesian, isTrue);
      expect(manager.locale, const Locale('id', 'ID'));
    });

    test('setLocale should update locale and save to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final manager = LanguageManager();
      await Future.delayed(const Duration(milliseconds: 100));

      await manager.setLocale(const Locale('id', 'ID'));

      expect(manager.locale, const Locale('id', 'ID'));
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_language'), 'id');
    });

    test('toggleLanguage should switch between English and Indonesian', () async {
      SharedPreferences.setMockInitialValues({});
      final manager = LanguageManager();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(manager.isEnglish, isTrue);

      await manager.toggleLanguage();
      expect(manager.isIndonesian, isTrue);

      await manager.toggleLanguage();
      expect(manager.isEnglish, isTrue);
    });

    test('getLanguageName should return correct name based on current locale', () async {
      SharedPreferences.setMockInitialValues({});
      final manager = LanguageManager();
      await Future.delayed(const Duration(milliseconds: 100));

      // When English is selected
      expect(manager.getLanguageName('en'), 'English');
      expect(manager.getLanguageName('id'), 'Indonesian');

      await manager.setIndonesian();

      // When Indonesian is selected
      expect(manager.getLanguageName('en'), 'Inggris');
      expect(manager.getLanguageName('id'), 'Indonesia');
    });

    test('should notify listeners when locale changes', () async {
      SharedPreferences.setMockInitialValues({});
      final manager = LanguageManager();
      await Future.delayed(const Duration(milliseconds: 100));

      int notifyCount = 0;
      manager.addListener(() {
        notifyCount++;
      });

      await manager.setIndonesian();
      await manager.setEnglish();

      expect(notifyCount, greaterThanOrEqualTo(2));
    });

    test('locale getter should return current Locale object', () async {
      SharedPreferences.setMockInitialValues({});
      final manager = LanguageManager();
      await Future.delayed(const Duration(milliseconds: 100));

      final locale = manager.locale;
      
      expect(locale, isA<Locale>());
      expect(locale.languageCode, 'en');
    });
  });
}
