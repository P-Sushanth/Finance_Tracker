import 'package:flutter/material.dart';

/// Grounded minimalist color palette adhering to the Nordic / Japanese aesthetic
/// defined in AGENTS.md (Charcoal, Warm Linen, Muted Sage, Soft Terracotta)
/// with high-contrast typography and clear visual legibility.
class AppColors {
  AppColors._();

  // Backgrounds & Surfaces (Crisp Warm Linen & Deep Slate)
  static const Color bgLight = Color(0xFFF7F6F2); // Warm Linen Light
  static const Color bgDark = Color(0xFF141618); // Deep Slate Dark
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1F2224);
  static const Color cardBorderLight = Color(0xFFDCD8CF); // High contrast border
  static const Color cardBorderDark = Color(0xFF33373A);

  // Typography & Neutrals - High Contrast for effortless reading
  static const Color textPrimaryLight = Color(0xFF1E211F); // Crisp Obsidian
  static const Color textSecondaryLight = Color(0xFF4A524D); // High contrast graphite (AAA compliant)
  static const Color textPrimaryDark = Color(0xFFF5F5F3);
  static const Color textSecondaryDark = Color(0xFFCBD0CA); // High contrast light neutral
  static const Color neutralSlate = Color(0xFF64748B); // Distinct slate
  static const Color slateMuted = Color(0xFF6B7280);

  // Primary Charcoal
  static const Color charcoal = Color(0xFF222B2F);
  static const Color charcoalLight = Color(0xFF333E44);

  // Growth / Investments (Rich Forest Sage - readable on light & dark)
  static const Color sage = Color(0xFF24664F); // Rich forest sage (was #4D7266)
  static const Color sageLight = Color(0xFFE2EFE9);
  static const Color sageMuted = Color(0xFF4A7D6B);

  // Outflow / Expenses / Caution (Vibrant Terracotta / Brick - readable)
  static const Color terracotta = Color(0xFFB53B25); // Rich brick terracotta (was #BA4E3B)
  static const Color terracottaLight = Color(0xFFFCEBE7);
  static const Color terracottaMuted = Color(0xFF9E3420);
}
