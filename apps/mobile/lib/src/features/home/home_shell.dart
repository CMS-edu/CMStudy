import 'package:flutter/material.dart';

import '../../core/local_reminders.dart';
import '../../state/app_controller.dart';
import '../missions/missions_screen.dart';
import '../settings/settings_screen.dart';
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
  void initState() {
    super.initState();
    LocalReminders.listenForLaunchActions(_handleLaunchAction);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final action = await LocalReminders.consumeLaunchAction();
      if (action != null) _handleLaunchAction(action);
    });
  }

  void _handleLaunchAction(String action) {
    if (!mounted) return;
    if (action == 'start_study') {
      setState(() => index = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(controller: widget.controller),
      FocusTimerScreen(controller: widget.controller),
      MissionsScreen(
        controller: widget.controller,
        onStartStudy: () => setState(() => index = 1),
      ),
      StatsScreen(controller: widget.controller),
      SubjectsScreen(controller: widget.controller),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.primary.withAlpha(24),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withAlpha(60),
                ),
              ),
              child: Icon(
                Icons.bolt_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            const Text('CMStudy'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: widget.controller.loadDashboard,
            icon: const Icon(Icons.sync_outlined),
            tooltip: '새로고침',
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(controller: widget.controller),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined),
            tooltip: '설정',
          ),
        ],
      ),
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: '작전판',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: '기록',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: '미션',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: '분석',
          ),
          NavigationDestination(
            icon: Icon(Icons.palette_outlined),
            selectedIcon: Icon(Icons.palette),
            label: '과목',
          ),
        ],
      ),
    );
  }
}
