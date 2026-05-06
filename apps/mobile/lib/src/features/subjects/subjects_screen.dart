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
    final target = controller.subjects.fold<int>(
      0,
      (sum, subject) => sum + subject.targetMinutesPerDay,
    );
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
        children: [
          Text(
            '과목 관리',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            '과목별 목표와 색상을 정하면 추천과 통계가 더 정확해집니다.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.track_changes_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '하루 전체 목표',
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatMinutes(target),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                  Text('${controller.subjects.length}개'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (controller.subjects.isEmpty)
            const _EmptySubjects()
          else
            ...controller.subjects.map(
              (subject) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SubjectTile(
                  subject: subject,
                  onEdit: () => showSubjectSheet(context, controller, subject),
                  onDelete: () => confirmDelete(context, controller, subject),
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

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({
    required this.subject,
    required this.onEdit,
    required this.onDelete,
  });

  final StudySubject subject;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = parseColor(subject.color);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            subject.name.characters.first,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(subject.name),
        subtitle: Text('하루 목표 ${formatMinutes(subject.targetMinutesPerDay)}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('수정')),
            PopupMenuItem(value: 'delete', child: Text('삭제')),
          ],
        ),
      ),
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
        child: Text('아직 과목이 없습니다. 오른쪽 아래 버튼으로 첫 과목을 추가하세요.'),
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
      content: const Text('연결된 계획은 함께 삭제될 수 있습니다. 계속할까요?'),
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
]) async {
  final nameController = TextEditingController(text: subject?.name ?? '');
  var color = subject?.color ?? subjectColors.first;
  var targetMinutes = subject?.targetMinutesPerDay ?? 60;

  final draft = await showModalBottomSheet<_SubjectDraft>(
    context: context,
    isScrollControlled: true,
    requestFocus: false,
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
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '과목명'),
                ),
                const SizedBox(height: 16),
                const Text('색상', style: TextStyle(fontWeight: FontWeight.w900)),
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
                              ? Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  width: 3,
                                )
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
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    Navigator.pop(
                      context,
                      _SubjectDraft(
                        name: name,
                        color: color,
                        targetMinutes: targetMinutes,
                      ),
                    );
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
  ).whenComplete(nameController.dispose);

  if (draft == null) return;
  await Future<void>.delayed(const Duration(milliseconds: 300));
  if (subject == null) {
    await controller.createSubject(
      name: draft.name,
      color: draft.color,
      targetMinutesPerDay: draft.targetMinutes,
    );
  } else {
    await controller.updateSubject(
      id: subject.id,
      name: draft.name,
      color: draft.color,
      targetMinutesPerDay: draft.targetMinutes,
    );
  }
}

class _SubjectDraft {
  const _SubjectDraft({
    required this.name,
    required this.color,
    required this.targetMinutes,
  });

  final String name;
  final String color;
  final int targetMinutes;
}
