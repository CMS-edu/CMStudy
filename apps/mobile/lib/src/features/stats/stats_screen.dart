import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../../models/models.dart';
import '../../state/app_controller.dart';
import '../home/dashboard_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final daily = controller.stats.daily;
    final maxMinutes = daily.fold<int>(
      1,
      (max, item) => item.minutes > max ? item.minutes : max,
    );
    final subjectEntries = controller.stats.subjectMinutes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final todayEntries = controller.stats.todaySubjectMinutes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '공부 통계',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _StatValue(
                    label: '오늘',
                    value: formatMinutes(controller.stats.focusedToday),
                  ),
                ),
                Expanded(
                  child: _StatValue(
                    label: '최근 7일',
                    value: formatMinutes(controller.stats.weeklyTotal),
                  ),
                ),
                Expanded(
                  child: _StatValue(
                    label: '전체',
                    value: formatMinutes(controller.stats.totalMinutes),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _SubjectStatsCard(
          title: '오늘 과목별 공부량',
          entries: todayEntries,
          subjects: controller.subjects,
          emptyText: '오늘 저장된 공부 기록이 없습니다.',
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '7일 기록',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                if (daily.every((item) => item.minutes == 0))
                  Column(
                    children: [
                      Image.asset(AppAssets.emptyStats, height: 160),
                      const SizedBox(height: 10),
                      const Text(
                        '아직 집중 기록이 없습니다.',
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    height: 220,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: daily.map((item) {
                        final height = 20 + (item.minutes / maxMinutes) * 160;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: height,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(item.date.substring(5)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _SubjectStatsCard(
          title: '이번 주 과목별 공부량',
          entries: subjectEntries,
          subjects: controller.subjects,
          emptyText: '이번 주 과목별 기록이 아직 없습니다.',
        ),
      ],
    );
  }
}

class _SubjectStatsCard extends StatelessWidget {
  const _SubjectStatsCard({
    required this.title,
    required this.entries,
    required this.subjects,
    required this.emptyText,
  });

  final String title;
  final List<MapEntry<String, int>> entries;
  final List<StudySubject> subjects;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final maxMinutes = entries.fold<int>(
      1,
      (max, item) => item.value > max ? item.value : max,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              Text(emptyText, style: const TextStyle(color: Colors.blueGrey))
            else
              ...entries.map((entry) {
                final subject = findSubjectByName(subjects, entry.key);
                final color = parseColor(subject?.color ?? '#2563EB');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(radius: 7, backgroundColor: color),
                          const SizedBox(width: 10),
                          Expanded(child: Text(entry.key)),
                          Text(formatMinutes(entry.value)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: (entry.value / maxMinutes).clamp(0.0, 1.0),
                          minHeight: 7,
                          color: color,
                          backgroundColor: color.withAlpha(28),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

StudySubject? findSubjectByName(List<StudySubject> subjects, String name) {
  for (final subject in subjects) {
    if (subject.name == name) return subject;
  }
  return null;
}

class _StatValue extends StatelessWidget {
  const _StatValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.blueGrey)),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
