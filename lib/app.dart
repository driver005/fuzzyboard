import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/providers/app_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/screen_registry.dart';
import 'core/providers/cms_provider.dart';
import 'core/providers/gamification_provider.dart';
import 'core/routing/app_router.dart';
import 'l10n/app_localizations.dart';

class FuzzyBoardApp extends StatefulWidget {
  const FuzzyBoardApp({super.key});

  @override
  State<FuzzyBoardApp> createState() => _FuzzyBoardAppState();
}

class _FuzzyBoardAppState extends State<FuzzyBoardApp> {
  late final AuthProvider authProvider;
  late final GoRouter router;

  @override
  void initState() {
    super.initState();
    authProvider = AuthProvider();
    router = createRouter(authProvider);
  }

  @override
  void dispose() {
    authProvider.dispose();
    router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ScreenRegistryProvider()),
        ChangeNotifierProvider(create: (_) => CmsProvider()),
        ChangeNotifierProvider(create: (_) => GamificationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp.router(
          title: 'FuzzyBoard',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: router,
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
