import 'package:flutter/material.dart';

enum CmThemePreset { graphite, forest, dawn, ink }

class CmThemeProfile {
  const CmThemeProfile({
    required this.preset,
    required this.label,
    required this.description,
    required this.seedColor,
    required this.lightBackground,
    required this.darkBackground,
    required this.lightSurface,
    required this.darkSurface,
  });

  final CmThemePreset preset;
  final String label;
  final String description;
  final Color seedColor;
  final Color lightBackground;
  final Color darkBackground;
  final Color lightSurface;
  final Color darkSurface;
}

const cmThemeProfiles = [
  CmThemeProfile(
    preset: CmThemePreset.graphite,
    label: '그래파이트',
    description: '차분한 기본 업무형 테마',
    seedColor: Color(0xFF2563EB),
    lightBackground: Color(0xFFF5F7FB),
    darkBackground: Color(0xFF0B1120),
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF111827),
  ),
  CmThemeProfile(
    preset: CmThemePreset.forest,
    label: '포레스트',
    description: '눈이 편한 녹색 집중 테마',
    seedColor: Color(0xFF059669),
    lightBackground: Color(0xFFF3F8F6),
    darkBackground: Color(0xFF071A16),
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF10201C),
  ),
  CmThemeProfile(
    preset: CmThemePreset.dawn,
    label: '던',
    description: '따뜻하지만 과하지 않은 테마',
    seedColor: Color(0xFFEA580C),
    lightBackground: Color(0xFFFAF7F2),
    darkBackground: Color(0xFF1B1110),
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF211817),
  ),
  CmThemeProfile(
    preset: CmThemePreset.ink,
    label: '잉크',
    description: '고대비 다크 중심 테마',
    seedColor: Color(0xFF0891B2),
    lightBackground: Color(0xFFF4F8FA),
    darkBackground: Color(0xFF06131A),
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF0D1B24),
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
  final scheme = ColorScheme.fromSeed(
    seedColor: profile.seedColor,
    brightness: brightness,
  );
  final background = isDark ? profile.darkBackground : profile.lightBackground;
  final surface = isDark ? profile.darkSurface : profile.lightSurface;
  final outline = isDark ? const Color(0xFF263247) : const Color(0xFFE0E7EF);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    visualDensity: VisualDensity.standard,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: background,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: outline),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: surface,
      indicatorColor: scheme.primaryContainer,
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
        minimumSize: const Size(48, 46),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 46),
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: scheme.primary, width: 1.6),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(color: outline),
      labelStyle: const TextStyle(fontWeight: FontWeight.w800),
    ),
    dividerTheme: DividerThemeData(color: outline),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
