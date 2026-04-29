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
            '${controller.user?.nickname ?? ''}님의 공부',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            '과목별 스탑워치로 오늘 공부량을 쌓아가세요.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: '오늘 누적',
                  value: formatMinutes(controller.stats.focusedToday),
                  icon: Icons.timer_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: '이번 주',
                  value: formatMinutes(controller.stats.weeklyTotal),
                  icon: Icons.calendar_view_week_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _MetricCard(
            label: '전체 누적',
            value: formatMinutes(controller.stats.totalMinutes),
            icon: Icons.all_inclusive,
          ),
          const SizedBox(height: 18),
          const _SectionTitle(title: '오늘 과목별 공부량'),
          const SizedBox(height: 10),
          if (controller.subjects.isEmpty)
            const _EmptyCard(text: '과목 탭에서 과목을 추가하세요.')
          else
            ...controller.subjects.map(
              (subject) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SubjectProgressTile(
                  subject: subject,
                  minutes:
                      controller.stats.todaySubjectMinutes[subject.name] ?? 0,
                ),
              ),
            ),
          if (controller.showPlansOnHome) ...[
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
          ],
        ],
      ),
    );
  }
}

class _SubjectProgressTile extends StatelessWidget {
  const _SubjectProgressTile({required this.subject, required this.minutes});

  final StudySubject subject;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    final color = parseColor(subject.color);
    final progress = subject.targetMinutesPerDay == 0
        ? 0.0
        : (minutes / subject.targetMinutesPerDay).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color,
                  child: Text(
                    subject.name.characters.first,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '목표 ${formatMinutes(subject.targetMinutesPerDay)}',
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatMinutes(minutes),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                color: color,
                backgroundColor: color.withAlpha(28),
              ),
            ),
          ],
        ),
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
