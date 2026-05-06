import 'package:flutter/material.dart';

import 'core/api_client.dart';
import 'core/app_theme.dart';
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
  late bool isInitialized;
  late bool isAuthenticated;
  late ThemeMode themeMode;
  late CmThemePreset themePreset;

  @override
  void initState() {
    super.initState();
    controller = AppController(ApiClient());
    isInitialized = controller.isInitialized;
    isAuthenticated = controller.isAuthenticated;
    themeMode = controller.themeMode;
    themePreset = controller.themePreset;
    controller.addListener(syncAppFrame);
    controller.restoreSession();
  }

  @override
  void dispose() {
    controller.removeListener(syncAppFrame);
    controller.dispose();
    super.dispose();
  }

  void syncAppFrame() {
    final nextInitialized = controller.isInitialized;
    final nextAuthenticated = controller.isAuthenticated;
    final nextThemeMode = controller.themeMode;
    final nextThemePreset = controller.themePreset;
    if (nextInitialized == isInitialized &&
        nextAuthenticated == isAuthenticated &&
        nextThemeMode == themeMode &&
        nextThemePreset == themePreset) {
      return;
    }
    setState(() {
      isInitialized = nextInitialized;
      isAuthenticated = nextAuthenticated;
      themeMode = nextThemeMode;
      themePreset = nextThemePreset;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProfile = cmThemeProfile(themePreset);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CMStudy',
      themeMode: themeMode,
      theme: buildCmStudyTheme(themeProfile, Brightness.light),
      darkTheme: buildCmStudyTheme(themeProfile, Brightness.dark),
      home: _ControllerHome(
        controller: controller,
        isAuthenticated: isAuthenticated,
        isInitialized: isInitialized,
      ),
    );
  }
}

class _ControllerHome extends StatelessWidget {
  const _ControllerHome({
    required this.controller,
    required this.isAuthenticated,
    required this.isInitialized,
  });

  final AppController controller;
  final bool isAuthenticated;
  final bool isInitialized;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (!isInitialized) return const _SplashScreen();
        if (isAuthenticated) return HomeShell(controller: controller);
        return LoginScreen(controller: controller);
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
