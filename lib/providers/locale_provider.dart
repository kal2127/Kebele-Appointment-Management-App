import 'package:flutter/material.dart';

import '../utils/language_preference.dart';

class LocaleProvider extends ChangeNotifier {
  LocaleProvider(this._languagePreference);

  final LanguagePreference _languagePreference;
  Locale _locale = LanguagePreference.defaultLocale;
  bool _isLoaded = false;

  Locale get locale => _locale;
  bool get isLoaded => _isLoaded;

  Future<void> loadSavedLocale() async {
    _locale = await _languagePreference.loadLocale();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _languagePreference.saveLocale(locale);
    notifyListeners();
  }
}
