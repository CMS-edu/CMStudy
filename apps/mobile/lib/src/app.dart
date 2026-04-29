import 'package:flutter/material.dart';

import 'core/api_client.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_shell.dart';
import 'state/app_controller.dart';

class CmStudyApp extends StatefulWidget {
  const CmStudyApp({super.key});

  @override
  State<CmStudyApp> createState() => _CmStudyAppState();
}

class _CmStudyAppState extends State<CmStudyApp> {
  late final AppController controller;

  @override
  void initState() {
    super.initState();
    controller = AppController(ApiClient());
    controller.restoreSession();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CMStudy',
          themeMode: controller.themeMode,
          theme: buildTheme(controller.accentColor, Brightness.light),
          darkTheme: buildTheme(controller.accentColor, Brightness.dark),
          home: controller.isAuthenticated
              ? HomeShell(controller: controller)
              : controller.isInitialized
              ? LoginScreen(controller: controller)
              : const _SplashScreen(),
        );
      },
    );
  }
}

ThemeData buildTheme(Color seedColor, Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
  );
  final isDark = brightness == Brightness.dark;
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF6F7F9),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF6F7F9),
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: isDark ? const Color(0xFF111827) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        side: BorderSide(
          color: isDark ? const Color(0xFF243044) : const Color(0xFFE1E7EF),
        ),
      ),
    ),
  );
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
