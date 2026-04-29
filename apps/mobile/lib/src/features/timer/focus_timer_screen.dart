import 'dart:async';

import 'package:flutter/material.dart';

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
  int focusMinutes = 25;
  int remainingSeconds = 25 * 60;
  bool running = false;
  String? subjectId;

  @override
  void dispose() {
    ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '집중 타이머',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
            child: Column(
              children: [
                const Text('집중 세션', style: TextStyle(color: Colors.blueGrey)),
                const SizedBox(height: 12),
                Text(
                  '$minutes:$seconds',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: running ? null : start,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('시작'),
                    ),
                    OutlinedButton.icon(
                      onPressed: running ? pause : null,
                      icon: const Icon(Icons.pause),
                      label: const Text('일시정지'),
                    ),
                    OutlinedButton.icon(
                      onPressed: reset,
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
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String?>(
                  initialValue: subjectId,
                  decoration: const InputDecoration(
                    labelText: '기록할 과목',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('과목 선택 안 함'),
                    ),
                    ...widget.controller.subjects.map(
                      (subject) => DropdownMenuItem<String?>(
                        value: subject.id,
                        child: Text(subject.name),
                      ),
                    ),
                  ],
                  onChanged: running
                      ? null
                      : (value) => setState(() => subjectId = value),
                ),
                const SizedBox(height: 16),
                Text('집중 시간 ${formatMinutes(focusMinutes)}'),
                Slider(
                  value: focusMinutes.toDouble(),
                  min: 15,
                  max: 60,
                  divisions: 9,
                  label: formatMinutes(focusMinutes),
                  onChanged: running
                      ? null
                      : (value) {
                          setState(() {
                            focusMinutes = value.round();
                            remainingSeconds = focusMinutes * 60;
                          });
                        },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void start() {
    setState(() => running = true);
    ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (remainingSeconds <= 1) {
        ticker?.cancel();
        setState(() {
          running = false;
          remainingSeconds = focusMinutes * 60;
        });
        await widget.controller.recordFocusSession(
          minutes: focusMinutes,
          subjectId: subjectId,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('집중 기록을 저장했습니다.')));
        return;
      }
      setState(() => remainingSeconds -= 1);
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
      remainingSeconds = focusMinutes * 60;
    });
  }
}
