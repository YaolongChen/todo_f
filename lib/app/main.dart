import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/app/routes/app_router.dart';
import 'package:todo/shared/i18n/strings.g.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocaleSync();
  runApp(const ProviderScope(child: MainApp()));
}

/// Root widget: theme, translations and the router table.
///
/// [TranslationProvider] wraps `MaterialApp` so every screen below can read its
/// copy with `context.t` and rebuild when the locale changes (see
/// `lib/app/AGENTS.md`).
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return TranslationProvider(
      child: MaterialApp.router(
        onGenerateTitle: (context) => context.t.appTitle,
        theme: ThemeData(colorSchemeSeed: const Color(0xFF3F51B5)),
        locale: LocaleSettings.currentLocale.flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: appRouter,
      ),
    );
  }
}
