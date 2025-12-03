import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language manager for app-wide locale state
class LanguageManager extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  
  Locale _locale = const Locale('en', 'US');
  
  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  bool get isEnglish => _locale.languageCode == 'en';
  bool get isIndonesian => _locale.languageCode == 'id';

  LanguageManager() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_languageKey) ?? 'en';
    _locale = langCode == 'id' 
        ? const Locale('id', 'ID') 
        : const Locale('en', 'US');
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
  }

  Future<void> setEnglish() async {
    await setLocale(const Locale('en', 'US'));
  }

  Future<void> setIndonesian() async {
    await setLocale(const Locale('id', 'ID'));
  }

  Future<void> toggleLanguage() async {
    if (isEnglish) {
      await setIndonesian();
    } else {
      await setEnglish();
    }
  }

  /// Get language name in current locale
  String getLanguageName(String code) {
    if (_locale.languageCode == 'id') {
      return code == 'en' ? 'Inggris' : 'Indonesia';
    }
    return code == 'en' ? 'English' : 'Indonesian';
  }
}
