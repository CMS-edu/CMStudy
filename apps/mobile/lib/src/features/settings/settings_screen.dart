import 'package:flutter/material.dart';

import '../../state/app_controller.dart';
import '../home/dashboard_screen.dart';

const accentChoices = [
  Color(0xFF2563EB),
  Color(0xFF059669),
  Color(0xFF7C3AED),
  Color(0xFFEA580C),
  Color(0xFFDC2626),
  Color(0xFF0891B2),
  Color(0xFF475569),
];

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: '화면',
            children: [
              const Text('테마', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('시스템'),
                    icon: Icon(Icons.settings_suggest_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('라이트'),
                    icon: Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('다크'),
                    icon: Icon(Icons.dark_mode_outlined),
                  ),
                ],
                selected: {controller.themeMode},
                onSelectionChanged: (value) {
                  controller.setThemeMode(value.first);
                },
              ),
              const SizedBox(height: 18),
              const Text(
                '포인트 색상',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: accentChoices.map((color) {
                  final selected =
                      color.toARGB32() == controller.accentColorValue;
                  return InkWell(
                    onTap: () => controller.setAccentColor(color),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.onSurface,
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
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: '기록 화면',
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('이미지 표시'),
                subtitle: const Text('로그인, 빈 화면, 스탑워치 일러스트를 보여줍니다.'),
                value: controller.showImages,
                onChanged: controller.setShowImages,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('홈에서 계획도 보기'),
                subtitle: const Text('기본은 공부량 중심이고, 필요할 때만 계획을 표시합니다.'),
                value: controller.showPlansOnHome,
                onChanged: controller.setShowPlansOnHome,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('통계 촘촘하게 보기'),
                subtitle: const Text('요약 카드와 세부 지표를 더 많이 표시합니다.'),
                value: controller.denseStats,
                onChanged: controller.setDenseStats,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: '공부 기준',
            children: [
              _InfoRow(
                label: '오늘 목표',
                value: formatMinutes(
                  controller.subjects.fold<int>(
                    0,
                    (sum, subject) => sum + subject.targetMinutesPerDay,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const _InfoRow(label: '스탑워치 저장', value: '1분 단위 올림'),
              const SizedBox(height: 10),
              const _InfoRow(label: '동기화', value: 'Render 서버 자동 저장'),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: '계정',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: Text(controller.user?.nickname ?? '사용자'),
                subtitle: Text(controller.user?.email ?? ''),
              ),
              FilledButton.icon(
                onPressed: controller.logout,
                icon: const Icon(Icons.logout),
                label: const Text('로그아웃'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.blueGrey)),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}
