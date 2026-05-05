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
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      children: [
        Text(
          '집중 기록',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        const Text(
          '과목을 선택하고 실제 공부 시간을 그대로 누적합니다.',
          style: TextStyle(color: Colors.blueGrey),
        ),
        const SizedBox(height: 16),
        _TimerPanel(
          controller: widget.controller,
          subject: subject,
          elapsedSeconds: elapsedSeconds,
          running: running,
          onStartPause: subject == null
              ? null
              : running
              ? pause
              : start,
          onFinish: elapsedSeconds == 0 ? null : finish,
          onReset: elapsedSeconds == 0 ? null : reset,
        ),
        const SizedBox(height: 18),
        _SubjectPickerHeader(running: running),
        const SizedBox(height: 10),
        if (widget.controller.subjects.isEmpty)
          const _EmptySubjects()
        else
          ...widget.controller.subjects.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SubjectStopwatchTile(
                subject: item,
                selected: item.id == subject?.id,
                todayMinutes:
                    widget.controller.stats.todaySubjectMinutes[item.name] ?? 0,
                activeMinutes: item.id == subject?.id ? activeMinutes : 0,
                enabled: !running,
                onTap: () => setState(() => subjectId = item.id),
              ),
            ),
          ),
        const SizedBox(height: 10),
        _TodayTotalCard(
          minutes: widget.controller.stats.focusedToday + activeMinutes,
        ),
      ],
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
    setState(() => running = false);
    final minutes = (elapsedSeconds / 60).ceil().clamp(1, 720);
    final review = await showSessionReviewSheet(context, subject, minutes);
    if (review == null) return;

    await widget.controller.recordFocusSession(
      minutes: minutes,
      subjectId: subject.id,
      note: review.toNote(),
    );
    if (!mounted) return;
    setState(() => elapsedSeconds = 0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${subject.name} ${formatMinutes(minutes)} 저장')),
    );
  }
}

class _TimerPanel extends StatelessWidget {
  const _TimerPanel({
    required this.controller,
    required this.subject,
    required this.elapsedSeconds,
    required this.running,
    required this.onStartPause,
    required this.onFinish,
    required this.onReset,
  });

  final AppController controller;
  final StudySubject? subject;
  final int elapsedSeconds;
  final bool running;
  final VoidCallback? onStartPause;
  final VoidCallback? onFinish;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
        child: Column(
          children: [
            if (controller.showImages) ...[
              Image.asset(AppAssets.focusTimer, height: 112),
              const SizedBox(height: 10),
            ],
            if (subject == null)
              const Text('먼저 과목을 추가하세요')
            else
              _SubjectBadge(subject: subject!),
            const SizedBox(height: 14),
            Text(
              formatSeconds(elapsedSeconds),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              running ? '기록 중입니다' : '준비되면 시작하세요',
              style: TextStyle(
                color: running ? scheme.primary : Colors.blueGrey,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onStartPause,
                    icon: Icon(running ? Icons.pause : Icons.play_arrow),
                    label: Text(running ? '일시정지' : '시작'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  onPressed: onFinish,
                  icon: const Icon(Icons.check),
                  tooltip: '저장',
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  onPressed: onReset,
                  icon: const Icon(Icons.restart_alt),
                  tooltip: '초기화',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectBadge extends StatelessWidget {
  const _SubjectBadge({required this.subject});

  final StudySubject subject;

  @override
  Widget build(BuildContext context) {
    final color = parseColor(subject.color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 5, backgroundColor: color),
          const SizedBox(width: 8),
          Text(
            subject.name,
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _SubjectPickerHeader extends StatelessWidget {
  const _SubjectPickerHeader({required this.running});

  final bool running;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '과목 선택',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        Text(
          running ? '기록 중에는 변경할 수 없습니다' : '탭해서 선택',
          style: const TextStyle(color: Colors.blueGrey),
        ),
      ],
    );
  }
}

class _EmptySubjects extends StatelessWidget {
  const _EmptySubjects();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Text('과목 탭에서 과목을 먼저 추가하세요.'),
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
    final total = todayMinutes + activeMinutes;
    final progress = subject.targetMinutesPerDay == 0
        ? 0.0
        : (total / subject.targetMinutesPerDay).clamp(0.0, 1.0);
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('오늘 누적 ${formatMinutes(total)}'),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                color: color,
                backgroundColor: color.withAlpha(28),
              ),
            ),
          ],
        ),
        trailing: Text(
          '목표 ${formatMinutes(subject.targetMinutesPerDay)}',
          style: const TextStyle(color: Colors.blueGrey),
        ),
      ),
    );
  }
}

class _TodayTotalCard extends StatelessWidget {
  const _TodayTotalCard({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.summarize_outlined),
        title: const Text('오늘 전체 공부량'),
        subtitle: const Text('저장된 세션과 현재 진행 중인 시간을 합산합니다'),
        trailing: Text(
          formatMinutes(minutes),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class SessionReview {
  const SessionReview({
    required this.focusRating,
    required this.difficultyRating,
    required this.memo,
  });

  final int focusRating;
  final int difficultyRating;
  final String memo;

  String toNote() {
    final lines = [
      '집중도: $focusRating/5',
      '난이도: $difficultyRating/5',
      if (memo.trim().isNotEmpty) '메모: ${memo.trim()}',
    ];
    return lines.join('\n');
  }
}

Future<SessionReview?> showSessionReviewSheet(
  BuildContext context,
  StudySubject subject,
  int minutes,
) {
  final memoController = TextEditingController();
  var focus = 4;
  var difficulty = 3;

  return showModalBottomSheet<SessionReview>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              18,
              18,
              18,
              MediaQuery.of(context).viewInsets.bottom + 18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '세션 저장',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  '${subject.name} · ${formatMinutes(minutes)}',
                  style: const TextStyle(color: Colors.blueGrey),
                ),
                const SizedBox(height: 18),
                _RatingSelector(
                  label: '집중도',
                  value: focus,
                  onChanged: (value) => setModalState(() => focus = value),
                ),
                const SizedBox(height: 14),
                _RatingSelector(
                  label: '난이도',
                  value: difficulty,
                  onChanged: (value) => setModalState(() => difficulty = value),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: memoController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: '공부 내용 메모',
                    hintText: '예: 미적분 문제풀이, 오답 12번까지',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      SessionReview(
                        focusRating: focus,
                        difficultyRating: difficulty,
                        memo: memoController.text,
                      ),
                    );
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('저장'),
                ),
              ],
            ),
          );
        },
      );
    },
  ).whenComplete(memoController.dispose);
}

class _RatingSelector extends StatelessWidget {
  const _RatingSelector({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            final rating = index + 1;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == 4 ? 0 : 6),
                child: ChoiceChip(
                  label: Text('$rating'),
                  selected: value == rating,
                  onSelected: (_) => onChanged(rating),
                  showCheckmark: false,
                ),
              ),
            );
          }),
        ),
      ],
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
