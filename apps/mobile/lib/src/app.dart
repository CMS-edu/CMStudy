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
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2563EB),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF6F7F9),
            cardTheme: const CardThemeData(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                side: BorderSide(color: Color(0xFFE1E7EF)),
              ),
            ),
          ),
          home: controller.isAuthenticated
              ? HomeShell(controller: controller)
              : LoginScreen(controller: controller),
        );
      },
    );
  }
}
