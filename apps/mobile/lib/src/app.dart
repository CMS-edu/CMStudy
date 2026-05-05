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
          theme: buildCmStudyTheme(controller.themeProfile, Brightness.light),
          darkTheme: buildCmStudyTheme(
            controller.themeProfile,
            Brightness.dark,
          ),
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

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
