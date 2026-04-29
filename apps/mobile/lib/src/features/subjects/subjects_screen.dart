import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../state/app_controller.dart';
import '../home/dashboard_screen.dart';

const subjectColors = [
  '#2563EB',
  '#059669',
  '#B7791F',
  '#DC2626',
  '#7C3AED',
  '#0891B2',
  '#EA580C',
  '#475569',
];

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '과목 관리',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            '과목별 색상과 하루 목표 시간을 정해두면 계획과 통계가 보기 쉬워져요.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 16),
          ...controller.subjects.map(
            (subject) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
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
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await showSubjectSheet(context, controller, subject);
                      }
                      if (value == 'delete' && context.mounted) {
                        await confirmDelete(context, controller, subject);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('수정')),
                      PopupMenuItem(value: 'delete', child: Text('삭제')),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (controller.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                controller.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showSubjectSheet(context, controller),
        icon: const Icon(Icons.add),
        label: const Text('과목 추가'),
      ),
    );
  }
}

Future<void> confirmDelete(
  BuildContext context,
  AppController controller,
  StudySubject subject,
) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('${subject.name} 삭제'),
      content: const Text('연결된 계획도 함께 삭제될 수 있습니다. 계속할까요?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('삭제'),
        ),
      ],
    ),
  );

  if (shouldDelete == true) {
    await controller.deleteSubject(subject.id);
  }
}

Future<void> showSubjectSheet(
  BuildContext context,
  AppController controller, [
  StudySubject? subject,
]) {
  final nameController = TextEditingController(text: subject?.name ?? '');
  var color = subject?.color ?? subjectColors.first;
  var targetMinutes = subject?.targetMinutesPerDay ?? 60;

  return showModalBottomSheet<void>(
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
                  subject == null ? '과목 추가' : '과목 수정',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '과목명',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                const Text('색상', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: subjectColors.map((item) {
                    final selected = item == color;
                    return InkWell(
                      onTap: () => setModalState(() => color = item),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: parseColor(item),
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                        child: selected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('하루 목표 ${formatMinutes(targetMinutes)}'),
                Slider(
                  value: targetMinutes.toDouble(),
                  min: 20,
                  max: 240,
                  divisions: 11,
                  label: formatMinutes(targetMinutes),
                  onChanged: (value) {
                    setModalState(() => targetMinutes = value.round());
                  },
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    if (subject == null) {
                      await controller.createSubject(
                        name: name,
                        color: color,
                        targetMinutesPerDay: targetMinutes,
                      );
                    } else {
                      await controller.updateSubject(
                        id: subject.id,
                        name: name,
                        color: color,
                        targetMinutesPerDay: targetMinutes,
                      );
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(subject == null ? '추가' : '저장'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
