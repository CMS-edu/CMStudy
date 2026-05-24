import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../career/career_profile_screen.dart';
import '../../models/models.dart';
import '../../state/app_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final snapshot = StudyCoachSnapshot.from(controller);
    return RefreshIndicator(
      onRefresh: controller.loadDashboard,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
        children: [
          _CommandHero(controller: controller, snapshot: snapshot),
          const SizedBox(height: 14),
          _MetricStrip(snapshot: snapshot),
          const SizedBox(height: 18),
          const _CareerProfilePanel(),
          const SizedBox(height: 18),
          _RecommendationPanel(snapshot: snapshot),
          const SizedBox(height: 18),
          _SectionHeader(
            title: '과목 작전',
            trailing: '${controller.subjects.length}개 과목',
          ),
          const SizedBox(height: 10),
          if (controller.subjects.isEmpty)
            const _EmptyPanel(
              icon: Icons.auto_stories_outlined,
              title: '과목을 먼저 추가하세요',
              message: '과목별 목표를 정하면 추천 순서와 밸런스 분석이 살아납니다.',
            )
          else
            ...controller.subjects.map(
              (subject) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SubjectPlanRow(
                  subject: subject,
                  minutes:
                      controller.stats.todaySubjectMinutes[subject.name] ?? 0,
                ),
              ),
            ),
          if (controller.showPlansOnHome) ...[
            const SizedBox(height: 18),
            _SectionHeader(
              title: '오늘 계획',
              trailing: '${controller.openTaskCount}개 남음',
            ),
            const SizedBox(height: 10),
            if (controller.tasks.isEmpty)
              const _EmptyPanel(
                icon: Icons.checklist_outlined,
                title: '오늘 계획이 없습니다',
                message: '계획을 쓰지 않아도 스탑워치 기록만으로 충분히 분석됩니다.',
              )
            else
              ...controller.tasks
                  .take(5)
                  .map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _TaskRow(
                        task: task,
                        onToggle: () => controller.toggleTask(task.id),
                      ),
                    ),
                  ),
          ],
        ],
      ),
    );
  }
}

class StudyCoachSnapshot {
  const StudyCoachSnapshot({
    required this.todayMinutes,
    required this.weekMinutes,
    required this.totalMinutes,
    required this.dailyTarget,
    required this.targetRate,
    required this.balanceScore,
    required this.grade,
    required this.recommendedSubject,
    required this.recommendedReason,
  });

  final int todayMinutes;
  final int weekMinutes;
  final int totalMinutes;
  final int dailyTarget;
  final int targetRate;
  final int balanceScore;
  final String grade;
  final StudySubject? recommendedSubject;
  final String recommendedReason;

  factory StudyCoachSnapshot.from(AppController controller) {
    final dailyTarget = controller.subjects.fold<int>(
      0,
      (sum, subject) => sum + subject.targetMinutesPerDay,
    );
    final today = controller.stats.focusedToday;
    final targetRate = dailyTarget == 0
        ? 0
        : ((today / dailyTarget) * 100).round();
    final balance = calculateBalanceScore(
      controller.subjects,
      controller.stats.todaySubjectMinutes,
    );
    final recommended = recommendSubject(
      controller.subjects,
      controller.stats.todaySubjectMinutes,
    );
    return StudyCoachSnapshot(
      todayMinutes: today,
      weekMinutes: controller.stats.weeklyTotal,
      totalMinutes: controller.stats.totalMinutes,
      dailyTarget: dailyTarget,
      targetRate: targetRate,
      balanceScore: balance,
      grade: coachGrade(targetRate, balance),
      recommendedSubject: recommended,
      recommendedReason: recommendationReason(
        recommended,
        controller.stats.todaySubjectMinutes,
      ),
    );
  }
}

class _CareerProfilePanel extends StatefulWidget {
  const _CareerProfilePanel();

  @override
  State<_CareerProfilePanel> createState() => _CareerProfilePanelState();
}

class _CareerProfilePanelState extends State<_CareerProfilePanel> {
  late Future<List<CareerPath>> profileFuture;

  @override
  void initState() {
    super.initState();
    profileFuture = loadCareerProfile();
  }

  void refresh() {
    setState(() => profileFuture = loadCareerProfile());
  }

  Future<void> openProfile() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CareerProfileScreen()));
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FutureBuilder<List<CareerPath>>(
      future: profileFuture,
      builder: (context, snapshot) {
        final paths = snapshot.data ?? const <CareerPath>[];
        final hasProfile = paths.isNotEmpty;
        final subjects = paths
            .expand((path) => path.subjects)
            .toSet()
            .take(5)
            .toList();
        final majors = paths.expand((path) => path.majors).take(4).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: scheme.primary.withAlpha(24),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.route_outlined, color: scheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasProfile ? '내 진로 프로필' : '진로 프로필 설정',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            hasProfile
                                ? paths.map((path) => path.category).join(' · ')
                                : '관심 진로를 설정하면 추천 과목과 활동이 홈에 유지됩니다.',
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (hasProfile) ...[
                  const SizedBox(height: 12),
                  _MiniChips(title: '추천 과목', values: subjects),
                  _MiniChips(title: '관련 학과', values: majors),
                ],
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: openProfile,
                  icon: const Icon(Icons.edit_note_outlined),
                  label: Text(hasProfile ? '진로 프로필 수정' : '진로 프로필 만들기'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MiniChips extends StatelessWidget {
  const _MiniChips({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: values
                .map(
                  (value) => Chip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: scheme.primary.withAlpha(22),
                    side: BorderSide(color: scheme.primary.withAlpha(85)),
                    labelStyle: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                    label: Text(value),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CommandHero extends StatelessWidget {
  const _CommandHero({required this.controller, required this.snapshot});

  final AppController controller;
  final StudyCoachSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final profile = controller.themeProfile;
    final progress = (snapshot.targetRate / 100).clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final showArtwork =
            controller.showImages && constraints.maxWidth >= 350;
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: scheme.primary.withAlpha(48)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.alphaBlend(
                  profile.seedColor.withAlpha(34),
                  scheme.surface,
                ),
                Color.alphaBlend(
                  profile.secondaryColor.withAlpha(22),
                  scheme.surface,
                ),
              ],
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: profile.seedColor.withAlpha(
                          Theme.of(context).brightness == Brightness.dark
                              ? 42
                              : 24,
                        ),
                      ),
                      child: Text(
                        '오늘 진행률 ${snapshot.targetRate.clamp(0, 999)}%',
                        style: TextStyle(
                          color: profile.seedColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${controller.user?.nickname ?? '사용자'}님의 오늘 작전',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      snapshot.dailyTarget == 0
                          ? '과목 목표를 설정하면 오늘의 추천 루틴이 만들어집니다.'
                          : '목표 ${formatMinutes(snapshot.dailyTarget)} 중 ${formatMinutes(snapshot.todayMinutes)} 진행',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 9,
                        backgroundColor: scheme.surface.withAlpha(150),
                      ),
                    ),
                  ],
                ),
              ),
              if (showArtwork) ...[
                const SizedBox(width: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    AppAssets.focusTimer,
                    width: 92,
                    height: 92,
                    fit: BoxFit.cover,
                  ),
                ),
              ] else ...[
                const SizedBox(width: 14),
                _GradeBadge(grade: snapshot.grade),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _GradeBadge extends StatelessWidget {
  const _GradeBadge({required this.grade});

  final String grade;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Text(
        grade,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MetricStrip extends StatelessWidget {
  const _MetricStrip({required this.snapshot});

  final StudyCoachSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.75,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        _MetricTile(
          label: '오늘 누적',
          value: formatMinutes(snapshot.todayMinutes),
          icon: Icons.timer_outlined,
        ),
        _MetricTile(
          label: '이번 주',
          value: formatMinutes(snapshot.weekMinutes),
          icon: Icons.calendar_view_week_outlined,
        ),
        _MetricTile(
          label: '밸런스',
          value: '${snapshot.balanceScore}점',
          icon: Icons.balance_outlined,
        ),
        _MetricTile(
          label: '전체 누적',
          value: formatMinutes(snapshot.totalMinutes),
          icon: Icons.all_inclusive,
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: scheme.primary.withAlpha(
                  Theme.of(context).brightness == Brightness.dark ? 34 : 18,
                ),
              ),
              child: Icon(icon, color: scheme.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.blueGrey)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationPanel extends StatelessWidget {
  const _RecommendationPanel({required this.snapshot});

  final StudyCoachSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final subject = snapshot.recommendedSubject;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.psychology_alt_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '다음 추천',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subject == null ? '과목 목표를 먼저 설정하세요' : subject.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    snapshot.recommendedReason,
                    style: const TextStyle(color: Colors.blueGrey),
                  ),
                ],
              ),
            ),
            if (subject != null)
              CircleAvatar(
                backgroundColor: parseColor(subject.color),
                child: Text(
                  subject.name.characters.first,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SubjectPlanRow extends StatelessWidget {
  const _SubjectPlanRow({required this.subject, required this.minutes});

  final StudySubject subject;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    final color = parseColor(subject.color);
    final target = subject.targetMinutesPerDay;
    final progress = target == 0 ? 0.0 : (minutes / target).clamp(0.0, 1.0);
    final status = subjectStatus(minutes, target);
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
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        '목표 ${formatMinutes(target)} · ${status.label}',
                        style: TextStyle(color: status.color),
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

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task, required this.onToggle});

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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

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
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        if (trailing != null)
          Text(trailing!, style: const TextStyle(color: Colors.blueGrey)),
      ],
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(message, style: const TextStyle(color: Colors.blueGrey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubjectStatus {
  const SubjectStatus(this.label, this.color);

  final String label;
  final Color color;
}

SubjectStatus subjectStatus(int minutes, int target) {
  if (target <= 0) return const SubjectStatus('목표 없음', Colors.blueGrey);
  final ratio = minutes / target;
  if (ratio >= 1.25) return const SubjectStatus('초과 진행', Color(0xFF7C3AED));
  if (ratio >= 1) return const SubjectStatus('완료', Color(0xFF059669));
  if (ratio >= 0.65) return const SubjectStatus('순항', Color(0xFF2563EB));
  if (ratio > 0) return const SubjectStatus('보강 필요', Color(0xFFEA580C));
  return const SubjectStatus('미시작', Color(0xFF64748B));
}

StudySubject? recommendSubject(
  List<StudySubject> subjects,
  Map<String, int> todayMinutes,
) {
  if (subjects.isEmpty) return null;
  final sorted = [...subjects];
  sorted.sort((a, b) {
    final aGap = a.targetMinutesPerDay - (todayMinutes[a.name] ?? 0);
    final bGap = b.targetMinutesPerDay - (todayMinutes[b.name] ?? 0);
    return bGap.compareTo(aGap);
  });
  return sorted.first;
}

String recommendationReason(
  StudySubject? subject,
  Map<String, int> todayMinutes,
) {
  if (subject == null) return '과목 탭에서 하루 목표를 만들면 자동 추천이 시작됩니다.';
  final current = todayMinutes[subject.name] ?? 0;
  final gap = math.max(0, subject.targetMinutesPerDay - current);
  if (gap == 0) return '오늘 목표는 채웠습니다. 짧은 복습 세션으로 마무리해도 좋습니다.';
  return '목표까지 ${formatMinutes(gap)} 남았습니다. 기록 탭에서 바로 시작하세요.';
}

int calculateBalanceScore(
  List<StudySubject> subjects,
  Map<String, int> todayMinutes,
) {
  if (subjects.isEmpty) return 0;
  final totalTarget = subjects.fold<int>(
    0,
    (sum, subject) => sum + subject.targetMinutesPerDay,
  );
  final totalActual = subjects.fold<int>(
    0,
    (sum, subject) => sum + (todayMinutes[subject.name] ?? 0),
  );
  if (totalTarget == 0 || totalActual == 0) return 0;

  var drift = 0.0;
  for (final subject in subjects) {
    final targetShare = subject.targetMinutesPerDay / totalTarget;
    final actualShare = (todayMinutes[subject.name] ?? 0) / totalActual;
    drift += (targetShare - actualShare).abs();
  }
  return (100 - drift * 50).clamp(0, 100).round();
}

String coachGrade(int targetRate, int balanceScore) {
  final blended = (targetRate.clamp(0, 120) * 0.6) + (balanceScore * 0.4);
  if (blended >= 95) return 'S';
  if (blended >= 80) return 'A';
  if (blended >= 60) return 'B';
  if (blended >= 35) return 'C';
  return 'D';
}

String formatMinutes(int minutes) {
  if (minutes < 60) return '${minutes}분';
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return rest == 0 ? '${hours}시간' : '${hours}시간 ${rest}분';
}

Color parseColor(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  return Color(int.parse('FF$cleaned', radix: 16));
}
