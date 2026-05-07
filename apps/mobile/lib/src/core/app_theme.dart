import 'package:flutter/material.dart';

const cmCorner = 3.0;
const cmTightCorner = 2.0;
const cmControlCorner = 3.0;

enum CmThemePreset { graphite, forest, dawn, ink, studio, marine }

class CmThemeProfile {
  const CmThemeProfile({
    required this.preset,
    required this.label,
    required this.description,
    required this.seedColor,
    required this.secondaryColor,
    required this.tertiaryColor,
    required this.lightBackground,
    required this.darkBackground,
    required this.lightSurface,
    required this.darkSurface,
  });

  final CmThemePreset preset;
  final String label;
  final String description;
  final Color seedColor;
  final Color secondaryColor;
  final Color tertiaryColor;
  final Color lightBackground;
  final Color darkBackground;
  final Color lightSurface;
  final Color darkSurface;

  CmThemeProfile copyWith({
    String? label,
    String? description,
    Color? seedColor,
    Color? secondaryColor,
    Color? tertiaryColor,
    Color? lightBackground,
    Color? darkBackground,
    Color? lightSurface,
    Color? darkSurface,
  }) {
    return CmThemeProfile(
      preset: preset,
      label: label ?? this.label,
      description: description ?? this.description,
      seedColor: seedColor ?? this.seedColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      tertiaryColor: tertiaryColor ?? this.tertiaryColor,
      lightBackground: lightBackground ?? this.lightBackground,
      darkBackground: darkBackground ?? this.darkBackground,
      lightSurface: lightSurface ?? this.lightSurface,
      darkSurface: darkSurface ?? this.darkSurface,
    );
  }
}

const cmThemeProfiles = [
  CmThemeProfile(
    preset: CmThemePreset.graphite,
    label: '그래파이트',
    description: '가장 균형 잡힌 기본 집중 테마',
    seedColor: Color(0xFF1D4ED8),
    secondaryColor: Color(0xFF0F766E),
    tertiaryColor: Color(0xFFB45309),
    lightBackground: Color(0xFFF3F5F8),
    darkBackground: Color(0xFF080D16),
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF111827),
  ),
  CmThemeProfile(
    preset: CmThemePreset.forest,
    label: '포레스트',
    description: '장시간 기록에 편한 저자극 테마',
    seedColor: Color(0xFF047857),
    secondaryColor: Color(0xFF2563EB),
    tertiaryColor: Color(0xFFCA8A04),
    lightBackground: Color(0xFFF2F8F5),
    darkBackground: Color(0xFF071713),
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF10201C),
  ),
  CmThemeProfile(
    preset: CmThemePreset.dawn,
    label: '던',
    description: '아침 공부에 어울리는 따뜻한 테마',
    seedColor: Color(0xFFD97706),
    secondaryColor: Color(0xFF0E7490),
    tertiaryColor: Color(0xFFBE123C),
    lightBackground: Color(0xFFFAF6EE),
    darkBackground: Color(0xFF1B120C),
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF231A13),
  ),
  CmThemeProfile(
    preset: CmThemePreset.ink,
    label: '잉크',
    description: '어두운 환경에서 또렷한 테마',
    seedColor: Color(0xFF0E7490),
    secondaryColor: Color(0xFF7C3AED),
    tertiaryColor: Color(0xFF16A34A),
    lightBackground: Color(0xFFF3F8FA),
    darkBackground: Color(0xFF06131A),
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF0D1B24),
  ),
  CmThemeProfile(
    preset: CmThemePreset.studio,
    label: '스튜디오',
    description: '선명한 대비의 생산성 테마',
    seedColor: Color(0xFF4F46E5),
    secondaryColor: Color(0xFF0F766E),
    tertiaryColor: Color(0xFFDC2626),
    lightBackground: Color(0xFFF6F7FB),
    darkBackground: Color(0xFF0C0E1A),
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF151827),
  ),
  CmThemeProfile(
    preset: CmThemePreset.marine,
    label: '마린',
    description: '차갑고 깨끗한 분석 중심 테마',
    seedColor: Color(0xFF0369A1),
    secondaryColor: Color(0xFF059669),
    tertiaryColor: Color(0xFF9333EA),
    lightBackground: Color(0xFFF2F7FA),
    darkBackground: Color(0xFF07121D),
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF0E1B2A),
  ),
];

CmThemePreset parseThemePreset(String? value) {
  for (final preset in CmThemePreset.values) {
    if (preset.name == value) return preset;
  }
  return CmThemePreset.graphite;
}

CmThemeProfile cmThemeProfile(CmThemePreset preset) {
  return cmThemeProfiles.firstWhere((profile) => profile.preset == preset);
}

ThemeData buildCmStudyTheme(CmThemeProfile profile, Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final generatedScheme = ColorScheme.fromSeed(
    seedColor: profile.seedColor,
    brightness: brightness,
  );
  final background = isDark ? profile.darkBackground : profile.lightBackground;
  final surface = isDark ? profile.darkSurface : profile.lightSurface;
  final elevatedSurface = isDark
      ? Color.alphaBlend(Colors.white.withAlpha(10), surface)
      : Color.alphaBlend(profile.seedColor.withAlpha(8), surface);
  final outline = isDark ? const Color(0xFF334155) : const Color(0xFFD2DAE5);
  final subtleFill = isDark
      ? const Color(0xFF0E1626)
      : Color.alphaBlend(profile.seedColor.withAlpha(7), Colors.white);
  final scheme = generatedScheme.copyWith(
    primary: profile.seedColor,
    secondary: profile.secondaryColor,
    tertiary: profile.tertiaryColor,
    surface: surface,
    outline: outline,
    outlineVariant: outline.withAlpha(isDark ? 150 : 210),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    visualDensity: VisualDensity.standard,
    textTheme: Typography.material2021().black.apply(
      bodyColor: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF111827),
      displayColor: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: background.withAlpha(isDark ? 242 : 248),
      foregroundColor: scheme.onSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cmCorner),
        side: BorderSide(color: outline.withAlpha(isDark ? 210 : 255)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: surface,
      indicatorColor: profile.seedColor.withAlpha(isDark ? 42 : 30),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cmCorner),
      ),
      surfaceTintColor: Colors.transparent,
      height: 70,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w900
              : FontWeight.w700,
        );
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cmControlCorner),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cmControlCorner),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 44),
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cmControlCorner),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: subtleFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cmControlCorner),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cmControlCorner),
        borderSide: BorderSide(color: outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cmControlCorner),
        borderSide: BorderSide(color: scheme.primary, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: elevatedSurface,
      selectedColor: profile.seedColor.withAlpha(isDark ? 50 : 28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cmControlCorner),
      ),
      side: BorderSide(color: outline),
      labelStyle: const TextStyle(fontWeight: FontWeight.w800),
    ),
    dividerTheme: DividerThemeData(color: outline),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return profile.seedColor;
        return isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return profile.seedColor.withAlpha(isDark ? 80 : 58);
        }
        return outline.withAlpha(isDark ? 90 : 150);
      }),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return profile.seedColor.withAlpha(isDark ? 44 : 24);
          }
          return Colors.transparent;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return profile.seedColor;
          return scheme.onSurfaceVariant;
        }),
        side: WidgetStatePropertyAll(BorderSide(color: outline)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cmControlCorner),
          ),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: profile.seedColor,
      linearTrackColor: outline.withAlpha(isDark ? 70 : 115),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cmCorner),
      ),
    ),
  );
}
