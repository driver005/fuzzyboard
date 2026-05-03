import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/providers/app_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/screen_registry.dart';
import 'core/providers/cms_provider.dart';
import 'core/routing/app_router.dart';

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
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp.router(
          title: 'FuzzyBoard',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: router,
        ),
      ),
    );
  }
}
