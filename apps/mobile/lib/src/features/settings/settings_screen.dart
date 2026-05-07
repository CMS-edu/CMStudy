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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
        children: [
          _AppearancePreview(controller: controller),
          const SizedBox(height: 14),
          _SectionCard(
            icon: Icons.contrast_outlined,
            title: '화면 모드',
            subtitle: '밝기 기준을 선택합니다.',
            children: [
              _ThemeModeSelector(
                selected: controller.themeMode,
                onChanged: controller.setThemeMode,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            icon: Icons.palette_outlined,
            title: '테마 프리셋',
            subtitle: '앱 전체 색감과 표면 톤을 바꿉니다.',
            children: [
              _ThemePresetGrid(
                selected: controller.themePreset,
                onChanged: controller.setThemePreset,
              ),
              const SizedBox(height: 16),
              _AccentColorPicker(
                selected: controller.accentColor,
                profile: controller.themeProfile,
                onChanged: controller.setAccentColor,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            icon: Icons.tune_outlined,
            title: '커스터마이즈',
            subtitle: '기록 화면의 밀도와 장식을 조절합니다.',
            children: [
              _SettingSwitchTile(
                icon: Icons.image_outlined,
                title: '이미지 사용',
                subtitle: '로그인, 빈 화면, 스탑워치 일러스트를 표시합니다.',
                value: controller.showImages,
                onChanged: controller.setShowImages,
              ),
              _SettingSwitchTile(
                icon: Icons.dashboard_customize_outlined,
                title: '홈에 계획 표시',
                subtitle: '작전판 하단에 오늘 계획을 함께 보여줍니다.',
                value: controller.showPlansOnHome,
                onChanged: controller.setShowPlansOnHome,
              ),
              _SettingSwitchTile(
                icon: Icons.stacked_line_chart_outlined,
                title: '통계 자세히 보기',
                subtitle: '분석 화면에서 보조 지표와 메모를 더 촘촘히 표시합니다.',
                value: controller.denseStats,
                onChanged: controller.setDenseStats,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            icon: Icons.rule_outlined,
            title: '공부 기준',
            subtitle: '현재 설정된 목표와 저장 방식을 확인합니다.',
            children: [
              _InfoRow(
                icon: Icons.track_changes_outlined,
                label: '오늘 목표',
                value: formatMinutes(
                  controller.subjects.fold<int>(
                    0,
                    (sum, subject) => sum + subject.targetMinutesPerDay,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const _InfoRow(
                icon: Icons.timer_outlined,
                label: '세션 저장',
                value: '1분 단위',
              ),
              const SizedBox(height: 10),
              const _InfoRow(
                icon: Icons.cloud_done_outlined,
                label: '동기화',
                value: '서버 자동 저장',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            icon: Icons.person_outline,
            title: '계정',
            children: [
              _AccountPanel(controller: controller),
              const SizedBox(height: 12),
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

class _AppearancePreview extends StatelessWidget {
  const _AppearancePreview({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final profile = controller.themeProfile;
    final scheme = Theme.of(context).colorScheme;
    final targetMinutes = controller.subjects.fold<int>(
      0,
      (sum, subject) => sum + subject.targetMinutesPerDay,
    );
    final progress = targetMinutes == 0
        ? 0.0
        : (controller.stats.focusedToday / targetMinutes).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cmCorner),
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 4, color: profile.seedColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      _ThemeMark(profile: profile, size: 52),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${profile.label} 테마',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              themeModeLabel(controller.themeMode),
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.auto_awesome_outlined,
                        color: profile.tertiaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(cmTightCorner),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 9,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _PreviewChip(
                        color: profile.seedColor,
                        label:
                            '오늘 ${formatMinutes(controller.stats.focusedToday)}',
                      ),
                      _PreviewChip(
                        color: profile.secondaryColor,
                        label: '과목 ${controller.subjects.length}개',
                      ),
                      _PreviewChip(
                        color: profile.tertiaryColor,
                        label: '계획 ${controller.openTaskCount}개',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccentColorPicker extends StatelessWidget {
  const _AccentColorPicker({
    required this.selected,
    required this.profile,
    required this.onChanged,
  });

  final Color selected;
  final CmThemeProfile profile;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = [
      profile.seedColor,
      profile.secondaryColor,
      profile.tertiaryColor,
      const Color(0xFF2563EB),
      const Color(0xFF059669),
      const Color(0xFFD97706),
      const Color(0xFFDC2626),
      const Color(0xFF7C3AED),
      const Color(0xFF0E7490),
      const Color(0xFF334155),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '강조색',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: [
            for (final color in colors)
              _AccentSwatch(
                color: color,
                selected: color.toARGB32() == selected.toARGB32(),
                onTap: () => onChanged(color),
              ),
          ],
        ),
      ],
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '강조색 선택',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cmCorner),
        child: Container(
          width: 38,
          height: 38,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cmCorner),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(cmTightCorner),
              color: color,
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        ),
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({required this.selected, required this.onChanged});

  final ThemeMode selected;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<ThemeMode>(
        showSelectedIcon: false,
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
        selected: {selected},
        onSelectionChanged: (value) => onChanged(value.first),
      ),
    );
  }
}

class _ThemePresetGrid extends StatelessWidget {
  const _ThemePresetGrid({required this.selected, required this.onChanged});

  final CmThemePreset selected;
  final ValueChanged<CmThemePreset> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final tileWidth = compact
            ? constraints.maxWidth
            : (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final profile in cmThemeProfiles)
              SizedBox(
                width: tileWidth,
                child: _ThemePresetTile(
                  profile: profile,
                  selected: selected == profile.preset,
                  onTap: () => onChanged(profile.preset),
                ),
              ),
          ],
        );
      },
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
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? profile.seedColor.withAlpha(
              Theme.of(context).brightness == Brightness.dark ? 34 : 18,
            )
          : scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cmCorner),
        side: BorderSide(
          color: selected ? profile.seedColor : scheme.outlineVariant,
          width: selected ? 1.7 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cmCorner),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ThemeMark(profile: profile, size: 36),
                  const Spacer(),
                  Icon(
                    selected
                        ? Icons.check_circle
                        : themePresetIcon(profile.preset),
                    color: selected
                        ? profile.seedColor
                        : scheme.onSurfaceVariant,
                    size: selected ? 22 : 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                profile.label,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                profile.description,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeMark extends StatelessWidget {
  const _ThemeMark({required this.profile, required this.size});

  final CmThemeProfile profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cmCorner),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _ColorBlock(
              color: profile.seedColor,
              radius: const BorderRadius.horizontal(
                left: Radius.circular(cmTightCorner),
              ),
            ),
          ),
          Expanded(flex: 2, child: _ColorBlock(color: profile.secondaryColor)),
          Expanded(
            flex: 2,
            child: _ColorBlock(
              color: profile.tertiaryColor,
              radius: const BorderRadius.horizontal(
                right: Radius.circular(cmTightCorner),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorBlock extends StatelessWidget {
  const _ColorBlock({required this.color, this.radius = BorderRadius.zero});

  final Color color;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: radius),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cmCorner),
        color: color.withAlpha(
          Theme.of(context).brightness == Brightness.dark ? 42 : 24,
        ),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _SettingSwitchTile extends StatelessWidget {
  const _SettingSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(cmCorner),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(cmCorner),
                  color: scheme.primary.withAlpha(
                    Theme.of(context).brightness == Brightness.dark ? 32 : 18,
                  ),
                ),
                child: Icon(icon, size: 20, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cmCorner),
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: scheme.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cmCorner),
        color: scheme.surfaceContainerHighest.withAlpha(
          Theme.of(context).brightness == Brightness.dark ? 120 : 140,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _AccountPanel extends StatelessWidget {
  const _AccountPanel({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = controller.user?.nickname ?? '사용자';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cmCorner),
        color: scheme.primary.withAlpha(
          Theme.of(context).brightness == Brightness.dark ? 30 : 16,
        ),
        border: Border.all(color: scheme.primary.withAlpha(58)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(cmCorner),
            ),
            child: Text(
              name.characters.first,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(
                  controller.user?.email ?? '',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String themeModeLabel(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.light => '라이트 모드',
    ThemeMode.dark => '다크 모드',
    ThemeMode.system => '시스템 설정 사용',
  };
}

IconData themePresetIcon(CmThemePreset preset) {
  return switch (preset) {
    CmThemePreset.graphite => Icons.view_week_outlined,
    CmThemePreset.forest => Icons.eco_outlined,
    CmThemePreset.dawn => Icons.wb_twilight_outlined,
    CmThemePreset.ink => Icons.dark_mode_outlined,
    CmThemePreset.studio => Icons.auto_awesome_outlined,
    CmThemePreset.marine => Icons.water_drop_outlined,
  };
}
