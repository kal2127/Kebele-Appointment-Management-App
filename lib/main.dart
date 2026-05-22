import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/app_constants.dart';
import 'core/app_localizations.dart';
import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'database/local_database.dart';
import 'providers/appointment_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/service_provider.dart';
import 'services/api_client.dart';
import 'services/appointment_api_service.dart';
import 'services/auth_api_service.dart';
import 'services/service_api_service.dart';
import 'utils/language_preference.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  final localDatabase = LocalDatabase.instance;
  final localeProvider = LocaleProvider(LanguagePreference());
  await localeProvider.loadSavedLocale();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider(
          create: (_) => ServiceProvider(
            ServiceApiService(apiClient),
            localDatabase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AppointmentProvider(
            AppointmentApiService(apiClient),
            localDatabase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthApiService(apiClient)),
        ),
      ],
      child: const KebeleAppointmentApp(),
    ),
  );
}

class KebeleAppointmentApp extends StatelessWidget {
  const KebeleAppointmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.light(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
