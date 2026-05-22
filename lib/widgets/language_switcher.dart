import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_localizations.dart';
import '../providers/locale_provider.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return SegmentedButton<String>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(
          value: 'am',
          label: Text(context.tr('amharic')),
        ),
        ButtonSegment(
          value: 'en',
          label: Text(context.tr('english')),
        ),
      ],
      selected: {localeProvider.locale.languageCode},
      onSelectionChanged: (selection) {
        localeProvider.setLocale(Locale(selection.first));
      },
    );
  }
}
