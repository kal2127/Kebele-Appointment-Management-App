import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_constants.dart';

class LanguagePreference {
  static const defaultLocale = Locale(AppConstants.defaultLanguageCode);

  Future<Locale> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(AppConstants.languagePreferenceKey);
    if (languageCode == null) return defaultLocale;
    return Locale(languageCode);
  }

  Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.languagePreferenceKey,
      locale.languageCode,
    );
  }
}
