import 'package:flutter/material.dart';

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
              ],
            ),
          ),
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
                SizedBox(
                  height: 220,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: daily.isEmpty
                        ? const [
                            Expanded(
                              child: Center(
                                child: Text(
                                  '아직 집중 기록이 없습니다.',
                                  style: TextStyle(color: Colors.blueGrey),
                                ),
                              ),
                            ),
                          ]
                        : daily.map((item) {
                            final height =
                                20 + (item.minutes / maxMinutes) * 160;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: height,
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        borderRadius:
                                            const BorderRadius.vertical(
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
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '과목별 집중',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                if (subjectEntries.isEmpty)
                  const Text(
                    '과목별 기록이 아직 없습니다.',
                    style: TextStyle(color: Colors.blueGrey),
                  )
                else
                  ...subjectEntries.map((entry) {
                    final subject = findSubjectByName(
                      controller.subjects,
                      entry.key,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 7,
                            backgroundColor: parseColor(
                              subject?.color ?? '#2563EB',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(entry.key)),
                          Text(formatMinutes(entry.value)),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ],
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
