import 'package:flutter/material.dart';

import '../../state/app_controller.dart';
import '../planner/planner_screen.dart';
import '../stats/stats_screen.dart';
import '../subjects/subjects_screen.dart';
import '../timer/focus_timer_screen.dart';
import 'dashboard_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.controller});

  final AppController controller;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(controller: widget.controller),
      PlannerScreen(controller: widget.controller),
      SubjectsScreen(controller: widget.controller),
      FocusTimerScreen(controller: widget.controller),
      StatsScreen(controller: widget.controller),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('CMStudy'),
        actions: [
          IconButton(
            onPressed: widget.controller.loadDashboard,
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
          ),
          IconButton(
            onPressed: widget.controller.logout,
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
          ),
        ],
      ),
      body: screens[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: '계획',
          ),
          NavigationDestination(
            icon: Icon(Icons.palette_outlined),
            selectedIcon: Icon(Icons.palette),
            label: '과목',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: '기록',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '통계',
          ),
        ],
      ),
    );
  }
}
