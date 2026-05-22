import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;
  late final Map<String, String> _texts;

  static const supportedLocales = [
    Locale('am'),
    Locale('en'),
  ];

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  Future<void> load() async {
    final languageCode = locale.languageCode;
    final jsonText =
        await rootBundle.loadString('assets/translations/$languageCode.json');
    final jsonMap = json.decode(jsonText) as Map<String, dynamic>;
    _texts = jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }

  String translate(String key, {Map<String, String>? params}) {
    var value = _texts[key] ?? key;
    params?.forEach((paramKey, paramValue) {
      value = value.replaceAll('{$paramKey}', paramValue);
    });
    return value;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((supported) => supported.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension TranslationExtension on BuildContext {
  String tr(String key, {Map<String, String>? params}) {
    return AppLocalizations.of(this).translate(key, params: params);
  }
}
