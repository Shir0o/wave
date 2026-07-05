import 'package:flutter/material.dart';

class AppThemeColors {
  final Color bg;
  final Color heroTop;
  final Color heroBot;
  final Color surface;
  final Color surfaceSoft;
  final Color surfaceTint;
  final Color text;
  final Color text2;
  final Color text3;
  final Color accent;
  final Color accent2;
  final Color divider;
  final Color divider2;
  final Color onWave;
  final Color onWaveSh;
  final Color toastBg;
  final Color toastText;
  final Color shadow;
  final Color wave1;
  final Color wave2;
  final Color fillTop;
  final Color fillBot;
  final Color bar;
  final Color trackOff;

  AppThemeColors({
    required this.bg,
    required this.heroTop,
    required this.heroBot,
    required this.surface,
    required this.surfaceSoft,
    required this.surfaceTint,
    required this.text,
    required this.text2,
    required this.text3,
    required this.accent,
    required this.accent2,
    required this.divider,
    required this.divider2,
    required this.onWave,
    required this.onWaveSh,
    required this.toastBg,
    required this.toastText,
    required this.shadow,
    required this.wave1,
    required this.wave2,
    required this.fillTop,
    required this.fillBot,
    required this.bar,
    required this.trackOff,
  });

  static final light = AppThemeColors(
    bg: const Color(0xFFEEF8FF),
    heroTop: const Color(0xFFE9F6FF),
    heroBot: const Color(0xFFDCF0FF),
    surface: const Color(0xFFFFFFFF),
    surfaceSoft: const Color(0xFFE4F4FB),
    surfaceTint: const Color(0xFFF0F9FD),
    text: const Color(0xFF0B2B45),
    text2: const Color(0xFF5C7D96),
    text3: const Color(0xFF9BB4C8),
    accent: const Color(0xFF12B3C7),
    accent2: const Color(0xFF0D94A6),
    divider: const Color(0xFFEEF4F8),
    divider2: const Color(0xFFF0F6FA),
    onWave: const Color(0xFF0B2B45),
    onWaveSh: Colors.white.withOpacity(0.6),
    toastBg: const Color(0xFF0B2B45),
    toastText: const Color(0xFFFFFFFF),
    shadow: const Color(0xFF2589CF).withOpacity(0.16),
    wave1: const Color(0xFF5CC3EC),
    wave2: const Color(0xFF7FD4F2),
    fillTop: const Color(0xFF5CC3EC),
    fillBot: const Color(0xFF2589CF),
    bar: const Color(0xFFBFE6F4),
    trackOff: const Color(0xFFCFE6EC),
  );

  static final dark = AppThemeColors(
    bg: const Color(0xFF0A151F),
    heroTop: const Color(0xFF102232),
    heroBot: const Color(0xFF0B1926),
    surface: const Color(0xFF13212F),
    surfaceSoft: const Color(0xFF1C3446),
    surfaceTint: const Color(0xFF172A3B),
    text: const Color(0xFFE8F3FB),
    text2: const Color(0xFF9DB6C8),
    text3: const Color(0xFF6A8298),
    accent: const Color(0xFF3FD0E6),
    accent2: const Color(0xFF4CC8DB),
    divider: const Color(0xFF1F3346),
    divider2: const Color(0xFF1B2E40),
    onWave: const Color(0xFFEAF6FF),
    onWaveSh: Colors.black.withOpacity(0.45),
    toastBg: const Color(0xFF1C3446),
    toastText: const Color(0xFFEAF6FF),
    shadow: Colors.black.withOpacity(0.40),
    wave1: const Color(0xFF2F9FCE),
    wave2: const Color(0xFF3FB3DD),
    fillTop: const Color(0xFF2F9FCE),
    fillBot: const Color(0xFF155A8C),
    bar: const Color(0xFF22506B),
    trackOff: const Color(0xFF2B4459),
  );
}
