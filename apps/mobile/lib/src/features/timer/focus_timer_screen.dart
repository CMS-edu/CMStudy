import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../../models/models.dart';
import '../../state/app_controller.dart';
import '../home/dashboard_screen.dart';

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  Timer? ticker;
  String? subjectId;
  int elapsedSeconds = 0;
  bool running = false;

  StudySubject? get selectedSubject {
    for (final subject in widget.controller.subjects) {
      if (subject.id == subjectId) return subject;
    }
    return widget.controller.subjects.isEmpty
        ? null
        : widget.controller.subjects.first;
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller.subjects.isNotEmpty) {
      subjectId = widget.controller.subjects.first.id;
    }
  }

  @override
  void didUpdateWidget(covariant FocusTimerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (subjectId == null && widget.controller.subjects.isNotEmpty) {
      subjectId = widget.controller.subjects.first.id;
    }
  }

  @override
  void dispose() {
    ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subject = selectedSubject;
    final activeMinutes = (elapsedSeconds / 60).floor();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '공부 스탑워치',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            '과목을 고르고 공부한 시간을 그대로 누적하세요.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
              child: Column(
                children: [
                  if (widget.controller.showImages) ...[
                    Image.asset(AppAssets.focusTimer, height: 118),
                    const SizedBox(height: 12),
                  ],
                  if (subject == null)
                    const Text('먼저 과목을 추가하세요.')
                  else
                    _SubjectBadge(subject: subject),
                  const SizedBox(height: 14),
                  Text(
                    formatSeconds(elapsedSeconds),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: subject == null
                            ? null
                            : running
                            ? pause
                            : start,
                        icon: Icon(running ? Icons.pause : Icons.play_arrow),
                        label: Text(running ? '일시정지' : '시작'),
                      ),
                      OutlinedButton.icon(
                        onPressed: elapsedSeconds == 0 ? null : finish,
                        icon: const Icon(Icons.check),
                        label: const Text('기록 저장'),
                      ),
                      OutlinedButton.icon(
                        onPressed: elapsedSeconds == 0 ? null : reset,
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('초기화'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '과목 선택',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (widget.controller.subjects.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text('과목 탭에서 과목을 먼저 추가하세요.'),
              ),
            )
          else
            ...widget.controller.subjects.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SubjectStopwatchTile(
                  subject: item,
                  selected: item.id == subject?.id,
                  todayMinutes:
                      widget.controller.stats.todaySubjectMinutes[item.name] ??
                      0,
                  activeMinutes: item.id == subject?.id ? activeMinutes : 0,
                  enabled: !running,
                  onTap: () => setState(() => subjectId = item.id),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.summarize_outlined),
              title: const Text('오늘 전체 공부량'),
              subtitle: const Text('저장된 세션 기준'),
              trailing: Text(
                formatMinutes(
                  widget.controller.stats.focusedToday + activeMinutes,
                ),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void start() {
    setState(() => running = true);
    ticker?.cancel();
    ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => elapsedSeconds += 1);
    });
  }

  void pause() {
    ticker?.cancel();
    setState(() => running = false);
  }

  void reset() {
    ticker?.cancel();
    setState(() {
      running = false;
      elapsedSeconds = 0;
    });
  }

  Future<void> finish() async {
    final subject = selectedSubject;
    if (subject == null || elapsedSeconds == 0) return;
    ticker?.cancel();
    final minutes = (elapsedSeconds / 60).ceil().clamp(1, 720);
    await widget.controller.recordFocusSession(
      minutes: minutes,
      subjectId: subject.id,
    );
    if (!mounted) return;
    setState(() {
      running = false;
      elapsedSeconds = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${subject.name} ${formatMinutes(minutes)} 저장')),
    );
  }
}

class _SubjectBadge extends StatelessWidget {
  const _SubjectBadge({required this.subject});

  final StudySubject subject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: parseColor(subject.color).withAlpha(24),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 5, backgroundColor: parseColor(subject.color)),
          const SizedBox(width: 8),
          Text(
            subject.name,
            style: TextStyle(
              color: parseColor(subject.color),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectStopwatchTile extends StatelessWidget {
  const _SubjectStopwatchTile({
    required this.subject,
    required this.selected,
    required this.todayMinutes,
    required this.activeMinutes,
    required this.enabled,
    required this.onTap,
  });

  final StudySubject subject;
  final bool selected;
  final int todayMinutes;
  final int activeMinutes;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = parseColor(subject.color);
    return Card(
      color: selected ? color.withAlpha(18) : null,
      child: ListTile(
        enabled: enabled || selected,
        onTap: enabled ? onTap : null,
        leading: CircleAvatar(
          backgroundColor: color,
          child: selected
              ? const Icon(Icons.check, color: Colors.white)
              : Text(
                  subject.name.characters.first,
                  style: const TextStyle(color: Colors.white),
                ),
        ),
        title: Text(subject.name),
        subtitle: Text('오늘 누적 ${formatMinutes(todayMinutes + activeMinutes)}'),
        trailing: Text(
          '목표 ${formatMinutes(subject.targetMinutesPerDay)}',
          style: const TextStyle(color: Colors.blueGrey),
        ),
      ),
    );
  }
}

String formatSeconds(int totalSeconds) {
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  return [
    hours.toString().padLeft(2, '0'),
    minutes.toString().padLeft(2, '0'),
    seconds.toString().padLeft(2, '0'),
  ].join(':');
}
