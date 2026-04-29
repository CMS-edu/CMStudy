import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../state/app_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${controller.user?.nickname ?? ''}님의 오늘',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: '남은 계획',
                  value: '${controller.openTaskCount}개',
                  icon: Icons.assignment_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: '계획 시간',
                  value: formatMinutes(controller.plannedMinutesToday),
                  icon: Icons.event_available_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _MetricCard(
            label: '오늘 집중',
            value: formatMinutes(controller.stats.focusedToday),
            icon: Icons.local_fire_department_outlined,
          ),
          const SizedBox(height: 18),
          _SectionTitle(
            title: '오늘 할 일',
            trailing: '${controller.tasks.length}개',
          ),
          const SizedBox(height: 10),
          if (controller.tasks.isEmpty)
            const _EmptyCard(text: '오늘 계획이 아직 없습니다.')
          else
            ...controller.tasks
                .take(5)
                .map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _TaskTile(
                      task: task,
                      onToggle: () => controller.toggleTask(task.id),
                    ),
                  ),
                ),
          const SizedBox(height: 18),
          const _SectionTitle(title: '과목별 목표'),
          const SizedBox(height: 10),
          ...controller.subjects.map(
            (subject) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: parseColor(subject.color),
                    child: Text(
                      subject.name.characters.first,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(subject.name),
                  subtitle: Text(
                    '하루 목표 ${formatMinutes(subject.targetMinutesPerDay)}',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(label, style: const TextStyle(color: Colors.blueGrey)),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.onToggle});

  final StudyTask task;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: CheckboxListTile(
        value: task.isDone,
        onChanged: (_) => onToggle(),
        title: Text(task.title),
        subtitle: Text(
          '${task.subject.name} · ${formatMinutes(task.plannedMinutes)}',
        ),
        secondary: CircleAvatar(
          backgroundColor: parseColor(task.subject.color),
          radius: 10,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (trailing != null)
          Text(trailing!, style: const TextStyle(color: Colors.blueGrey)),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(text, style: const TextStyle(color: Colors.blueGrey)),
        ),
      ),
    );
  }
}

String formatMinutes(int minutes) {
  if (minutes < 60) return '$minutes분';
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return rest == 0 ? '$hours시간' : '$hours시간 $rest분';
}

Color parseColor(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  return Color(int.parse('FF$cleaned', radix: 16));
}
