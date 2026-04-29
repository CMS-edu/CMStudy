import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../../models/models.dart';
import '../../state/app_controller.dart';
import '../home/dashboard_screen.dart';

const periodLabels = {
  'day': '일',
  'week': '주',
  'month': '월',
  'year': '년',
  'total': '전체',
};

const periodSubtitles = {
  'day': '오늘의 과목별 집중 비율',
  'week': '이번 주 공부 리듬',
  'month': '이번 달 누적과 빈도',
  'year': '올해 월별 성장',
  'total': '전체 누적 기록',
};

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String period = 'day';

  @override
  Widget build(BuildContext context) {
    final stats = widget.controller.stats;
    final current = stats.periods[period] ?? StudyPeriodStats.empty;
    final entries = sortedSubjectEntries(current.subjectMinutes);
    final total = current.totalMinutes;
    final target = periodTarget(widget.controller.subjects, period);
    final targetRate = target == 0 ? 0 : ((total / target) * 100).round();
    final topSubject = entries.isEmpty ? '-' : entries.first.key;
    final studiedSubjectCount = entries
        .where((entry) => entry.value > 0)
        .length;

    return RefreshIndicator(
      onRefresh: widget.controller.loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '공부 통계',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            periodSubtitles[period] ?? '누적 공부 기록',
            style: const TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 16),
          _PeriodSelector(
            selected: period,
            onSelected: (value) => setState(() => period = value),
          ),
          const SizedBox(height: 16),
          _PeriodSummaryCard(
            label: periodLabels[period] ?? '',
            totalMinutes: total,
            targetRate: targetRate,
            activeDays: current.activeDays,
            averageMinutes: current.averageMinutes,
            bestDayMinutes: current.bestDayMinutes,
            studiedSubjectCount: studiedSubjectCount,
            topSubject: topSubject,
          ),
          const SizedBox(height: 16),
          _SubjectRatioCard(
            controller: widget.controller,
            entries: entries,
            totalMinutes: total,
          ),
          const SizedBox(height: 16),
          _FlowCard(period: period, stats: current),
          const SizedBox(height: 16),
          _InsightCard(
            controller: widget.controller,
            period: period,
            stats: current,
            entries: entries,
            target: target,
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: periodLabels.entries.map((entry) {
          final isSelected = selected == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (_) => onSelected(entry.key),
              labelStyle: TextStyle(
                fontWeight: FontWeight.w900,
                color: isSelected ? colorScheme.onPrimary : null,
              ),
              selectedColor: colorScheme.primary,
              showCheckmark: false,
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PeriodSummaryCard extends StatelessWidget {
  const _PeriodSummaryCard({
    required this.label,
    required this.totalMinutes,
    required this.targetRate,
    required this.activeDays,
    required this.averageMinutes,
    required this.bestDayMinutes,
    required this.studiedSubjectCount,
    required this.topSubject,
  });

  final String label;
  final int totalMinutes;
  final int targetRate;
  final int activeDays;
  final int averageMinutes;
  final int bestDayMinutes;
  final int studiedSubjectCount;
  final String topSubject;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$label 공부 시간',
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatMinutes(totalMinutes),
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                      ),
                    ],
                  ),
                ),
                _GoalRing(value: targetRate),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MiniStat(label: '목표 달성', value: '$targetRate%'),
                _MiniStat(label: '공부한 날', value: '$activeDays일'),
                _MiniStat(label: '하루 평균', value: formatMinutes(averageMinutes)),
                _MiniStat(label: '최고 기록', value: formatMinutes(bestDayMinutes)),
                _MiniStat(label: '공부 과목', value: '$studiedSubjectCount개'),
                _MiniStat(label: '최다 과목', value: topSubject),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalRing extends StatelessWidget {
  const _GoalRing({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final progress = (value / 100).clamp(0.0, 1.0);
    return SizedBox(
      width: 86,
      height: 86,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 9,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            strokeCap: StrokeCap.round,
          ),
          Text('$value%', style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _SubjectRatioCard extends StatelessWidget {
  const _SubjectRatioCard({
    required this.controller,
    required this.entries,
    required this.totalMinutes,
  });

  final AppController controller;
  final List<MapEntry<String, int>> entries;
  final int totalMinutes;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '과목별 비율',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text(
              '총 공부 시간 중 각 과목이 차지한 비중입니다.',
              style: TextStyle(color: Colors.blueGrey),
            ),
            const SizedBox(height: 16),
            if (entries.isEmpty)
              _EmptyStats(controller: controller)
            else
              Column(
                children: [
                  SizedBox(
                    height: 230,
                    child: CustomPaint(
                      painter: SubjectPiePainter(
                        entries: entries,
                        subjects: controller.subjects,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '총합',
                              style: TextStyle(color: Colors.blueGrey),
                            ),
                            Text(
                              formatMinutes(totalMinutes),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...entries.asMap().entries.map((ranked) {
                    final rank = ranked.key + 1;
                    final entry = ranked.value;
                    final subject = findSubjectByName(
                      controller.subjects,
                      entry.key,
                    );
                    final color = parseColor(subject?.color ?? '#2563EB');
                    final ratio = totalMinutes == 0
                        ? 0
                        : ((entry.value / totalMinutes) * 100).round();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SubjectRatioRow(
                        rank: rank,
                        name: entry.key,
                        minutes: entry.value,
                        ratio: ratio,
                        color: color,
                        maxMinutes: entries.first.value,
                      ),
                    );
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class SubjectPiePainter extends CustomPainter {
  SubjectPiePainter({required this.entries, required this.subjects});

  final List<MapEntry<String, int>> entries;
  final List<StudySubject> subjects;

  @override
  void paint(Canvas canvas, Size size) {
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.value);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 34
      ..strokeCap = StrokeCap.butt;

    if (total == 0) {
      paint.color = const Color(0xFFE2E8F0);
      canvas.drawCircle(center, radius - 18, paint);
      return;
    }

    var start = -math.pi / 2;
    for (final entry in entries) {
      final subject = findSubjectByName(subjects, entry.key);
      paint.color = parseColor(subject?.color ?? '#2563EB');
      final sweep = (entry.value / total) * math.pi * 2;
      canvas.drawArc(rect.deflate(18), start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant SubjectPiePainter oldDelegate) {
    return oldDelegate.entries != entries || oldDelegate.subjects != subjects;
  }
}

class _SubjectRatioRow extends StatelessWidget {
  const _SubjectRatioRow({
    required this.rank,
    required this.name,
    required this.minutes,
    required this.ratio,
    required this.color,
    required this.maxMinutes,
  });

  final int rank;
  final String name;
  final int minutes;
  final int ratio;
  final Color color;
  final int maxMinutes;

  @override
  Widget build(BuildContext context) {
    final progress = maxMinutes == 0
        ? 0.0
        : (minutes / maxMinutes).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                '$rank위',
                style: const TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            CircleAvatar(radius: 7, backgroundColor: color),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w800),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text('$ratio% · ${formatMinutes(minutes)}'),
          ],
        ),
        const SizedBox(height: 6),
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
    );
  }
}

class _FlowCard extends StatelessWidget {
  const _FlowCard({required this.period, required this.stats});

  final String period;
  final StudyPeriodStats stats;

  @override
  Widget build(BuildContext context) {
    final useMonthly = period == 'year' || period == 'total';
    final monthlyEntries = stats.monthlyMinutes.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final dailyEntries = stats.daily;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              useMonthly ? '월별 흐름' : '일별 흐름',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              useMonthly ? '긴 기간은 월 단위로 압축했습니다.' : '하루하루 누적 시간을 비교합니다.',
              style: const TextStyle(color: Colors.blueGrey),
            ),
            const SizedBox(height: 16),
            if (useMonthly)
              _BarChart(
                items: monthlyEntries
                    .map(
                      (entry) => ChartItem(entry.key.substring(5), entry.value),
                    )
                    .toList(),
              )
            else
              _BarChart(
                items: dailyEntries
                    .map(
                      (entry) =>
                          ChartItem(entry.date.substring(5), entry.minutes),
                    )
                    .toList(),
              ),
            if (!useMonthly && period == 'month') ...[
              const SizedBox(height: 18),
              _HeatGrid(days: dailyEntries),
            ],
          ],
        ),
      ),
    );
  }
}

class ChartItem {
  const ChartItem(this.label, this.minutes);

  final String label;
  final int minutes;
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.items});

  final List<ChartItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _SmallEmpty(text: '아직 표시할 흐름이 없습니다.');
    }

    final trimmed = items.length > 18
        ? items.sublist(items.length - 18)
        : items;
    final maxMinutes = trimmed.fold<int>(
      1,
      (max, item) => item.minutes > max ? item.minutes : max,
    );

    return SizedBox(
      height: 196,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: trimmed.map((item) {
          final height = 10 + (item.minutes / maxMinutes) * 136;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    item.minutes == 0 ? '' : compactMinutes(item.minutes),
                    style: Theme.of(context).textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: item.minutes == 0
                          ? Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest
                          : Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _HeatGrid extends StatelessWidget {
  const _HeatGrid({required this.days});

  final List<DailyFocus> days;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();
    final maxMinutes = days.fold<int>(
      1,
      (max, item) => item.minutes > max ? item.minutes : max,
    );
    final color = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '월간 출석 밀도',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: days.map((day) {
            final strength = day.minutes == 0
                ? 0.08
                : 0.22 + (day.minutes / maxMinutes) * 0.7;
            return Tooltip(
              message: '${day.date} · ${formatMinutes(day.minutes)}',
              child: Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: strength.clamp(0.08, 0.92)),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  day.date.substring(8),
                  style: TextStyle(
                    color: strength > 0.45 ? Colors.white : null,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.controller,
    required this.period,
    required this.stats,
    required this.entries,
    required this.target,
  });

  final AppController controller;
  final String period;
  final StudyPeriodStats stats;
  final List<MapEntry<String, int>> entries;
  final int target;

  @override
  Widget build(BuildContext context) {
    final targetGap = math.max(0, target - stats.totalMinutes);
    final totalDays = stats.daily.isEmpty ? 1 : stats.daily.length;
    final consistency = ((stats.activeDays / totalDays) * 100).round();
    final concentration = entries.isEmpty || stats.totalMinutes == 0
        ? 0
        : ((entries.first.value / stats.totalMinutes) * 100).round();
    final projected = projectedMinutes(period, stats);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '분석 메모',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            _InsightRow(
              icon: Icons.flag_outlined,
              title: target == 0 ? '목표 없음' : '목표까지 남은 시간',
              value: target == 0 ? '과목 목표를 설정하세요' : formatMinutes(targetGap),
            ),
            _InsightRow(
              icon: Icons.event_available_outlined,
              title: '꾸준함',
              value: '$consistency%',
            ),
            _InsightRow(
              icon: Icons.track_changes_outlined,
              title: '최다 과목 집중도',
              value: '$concentration%',
            ),
            if (projected > 0)
              _InsightRow(
                icon: Icons.trending_up_outlined,
                title: period == 'month' ? '월말 예상' : '올해 예상',
                value: formatMinutes(projected),
              ),
          ],
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Text(value, style: const TextStyle(color: Colors.blueGrey)),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.blueGrey)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _EmptyStats extends StatelessWidget {
  const _EmptyStats({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (controller.showImages) ...[
          Image.asset(AppAssets.emptyStats, height: 160),
          const SizedBox(height: 10),
        ],
        const Text(
          '아직 이 기간에 저장된 공부 기록이 없습니다.',
          style: TextStyle(color: Colors.blueGrey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SmallEmpty extends StatelessWidget {
  const _SmallEmpty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(text, style: const TextStyle(color: Colors.blueGrey)),
      ),
    );
  }
}

List<MapEntry<String, int>> sortedSubjectEntries(Map<String, int> minutes) {
  return minutes.entries.where((entry) => entry.value > 0).toList()
    ..sort((a, b) => b.value.compareTo(a.value));
}

StudySubject? findSubjectByName(List<StudySubject> subjects, String name) {
  for (final subject in subjects) {
    if (subject.name == name) return subject;
  }
  return null;
}

int periodTarget(List<StudySubject> subjects, String period) {
  final dailyTarget = subjects.fold<int>(
    0,
    (sum, subject) => sum + subject.targetMinutesPerDay,
  );
  final now = DateTime.now();
  return switch (period) {
    'day' => dailyTarget,
    'week' => dailyTarget * 7,
    'month' => dailyTarget * now.day,
    'year' => dailyTarget * dayOfYear(now),
    _ => 0,
  };
}

int projectedMinutes(String period, StudyPeriodStats stats) {
  final now = DateTime.now();
  if (stats.totalMinutes == 0) return 0;
  if (period == 'month') {
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return ((stats.totalMinutes / now.day) * daysInMonth).round();
  }
  if (period == 'year') {
    return ((stats.totalMinutes / dayOfYear(now)) *
            (DateTime(now.year).isLeapYear ? 366 : 365))
        .round();
  }
  return 0;
}

int dayOfYear(DateTime date) {
  return date.difference(DateTime(date.year)).inDays + 1;
}

String compactMinutes(int minutes) {
  if (minutes < 60) return '${minutes}분';
  final hours = minutes ~/ 60;
  return '${hours}h';
}

extension on DateTime {
  bool get isLeapYear {
    final year = this.year;
    return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
  }
}
