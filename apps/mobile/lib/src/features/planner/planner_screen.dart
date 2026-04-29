import 'package:flutter/material.dart';

import '../../state/app_controller.dart';
import '../home/dashboard_screen.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '공부 계획',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          if (controller.tasks.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(22),
                child: Text(
                  '오늘 계획을 추가해보세요.',
                  style: TextStyle(color: Colors.blueGrey),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ...controller.tasks.map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isDone,
                      onChanged: (_) => controller.toggleTask(task.id),
                    ),
                    title: Text(task.title),
                    subtitle: Text(
                      '${task.subject.name} · ${formatMinutes(task.plannedMinutes)}',
                    ),
                    trailing: IconButton(
                      onPressed: () => controller.deleteTask(task.id),
                      icon: const Icon(Icons.delete_outline),
                      tooltip: '삭제',
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.subjects.isEmpty
            ? null
            : () => _showTaskSheet(context, controller),
        icon: const Icon(Icons.add),
        label: const Text('계획 추가'),
      ),
    );
  }
}

Future<void> _showTaskSheet(BuildContext context, AppController controller) {
  final titleController = TextEditingController();
  var subjectId = controller.subjects.first.id;
  var minutes = 60;

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
                  '새 계획',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: subjectId,
                  decoration: const InputDecoration(
                    labelText: '과목',
                    border: OutlineInputBorder(),
                  ),
                  items: controller.subjects
                      .map(
                        (subject) => DropdownMenuItem(
                          value: subject.id,
                          child: Text(subject.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setModalState(() => subjectId = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '공부할 내용',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('목표 시간'),
                    Expanded(
                      child: Slider(
                        value: minutes.toDouble(),
                        min: 20,
                        max: 180,
                        divisions: 8,
                        label: formatMinutes(minutes),
                        onChanged: (value) {
                          setModalState(() => minutes = value.round());
                        },
                      ),
                    ),
                    SizedBox(
                      width: 76,
                      child: Text(
                        formatMinutes(minutes),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    await controller.createTask(
                      subjectId: subjectId,
                      title: title,
                      plannedMinutes: minutes,
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('추가'),
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
