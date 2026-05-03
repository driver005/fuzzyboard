import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/providers/app_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/screen_registry.dart';
import 'core/providers/cms_provider.dart';
import 'core/routing/app_router.dart';
import 'l10n/app_localizations.dart';

class FuzzyBoardApp extends StatelessWidget {
  const FuzzyBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ScreenRegistryProvider()),
        ChangeNotifierProvider(create: (_) => CmsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp.router(
          title: 'FuzzyBoard',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: appRouter,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
  }
}

/// Convenience extension so widgets can write `context.l10n.someKey`
/// instead of `AppLocalizations.of(context)!.someKey`.
extension ContextL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
