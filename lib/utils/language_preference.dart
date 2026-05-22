import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguagePreference {
  static const _languageKey = 'selected_language_code';
  static const defaultLocale = Locale('am');

  Future<Locale> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);
    if (languageCode == null) return defaultLocale;
    return Locale(languageCode);
  }

  Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
  }
}
