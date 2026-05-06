import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../state/app_controller.dart';
import '../home/dashboard_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
        children: [
          _SectionCard(
            title: '화면 모드',
            subtitle: '앱 전체의 밝기와 기본 분위기를 정합니다.',
            children: [
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
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: '테마 프리셋',
            subtitle: '색상, 표면 톤, 강조색을 한 번에 바꿉니다.',
            children: [
              ...cmThemeProfiles.map(
                (profile) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ThemePresetTile(
                    profile: profile,
                    selected: controller.themePreset == profile.preset,
                    onTap: () => controller.setThemePreset(profile.preset),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: '기록 화면',
            subtitle: '홈과 분석 화면에 표시할 정보량을 조절합니다.',
            children: [
              _SettingSwitchTile(
                title: '이미지 표시',
                subtitle: '로그인, 빈 화면, 스탑워치 일러스트를 표시합니다.',
                value: controller.showImages,
                onChanged: controller.setShowImages,
              ),
              _SettingSwitchTile(
                title: '작전판에 계획 표시',
                subtitle: '계획 기능을 쓰는 경우 홈 하단에 오늘 계획을 보여줍니다.',
                value: controller.showPlansOnHome,
                onChanged: controller.setShowPlansOnHome,
              ),
              _SettingSwitchTile(
                title: '분석 정보 촘촘히 보기',
                subtitle: '통계 화면에서 보조 지표와 분석 메모를 더 자세히 표시합니다.',
                value: controller.denseStats,
                onChanged: controller.setDenseStats,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: '공부 기준',
            subtitle: '과목 목표를 바탕으로 추천과 밸런스 점수가 계산됩니다.',
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
              const _InfoRow(label: '세션 저장', value: '1분 단위 반올림'),
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

class _SettingSwitchTile extends StatelessWidget {
  const _SettingSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.blueGrey)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ThemePresetTile extends StatelessWidget {
  const _ThemePresetTile({
    required this.profile,
    required this.selected,
    required this.onTap,
  });

  final CmThemeProfile profile;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            _ThemeSwatch(profile: profile),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.label,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    profile.description,
                    style: const TextStyle(color: Colors.blueGrey),
                  ),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle),
          ],
        ),
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({required this.profile});

  final CmThemeProfile profile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 34,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: profile.seedColor,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(7),
                ),
              ),
            ),
          ),
          Expanded(child: Container(color: profile.lightBackground)),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: profile.darkSurface,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
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
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: const TextStyle(color: Colors.blueGrey)),
            ],
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
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    );
  }
}
