import 'package:flutter/material.dart';

/// Grounded minimalist color palette adhering to the Nordic / Japanese aesthetic
/// defined in AGENTS.md (Charcoal, Warm Linen, Muted Sage, Soft Terracotta).
class AppColors {
  AppColors._();

  // Backgrounds & Surfaces
  static const Color bgLight = Color(0xFFF5F4F0); // Warm Linen Light
  static const Color bgDark = Color(0xFF1A1C1E); // Slate Dark
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF232628);
  static const Color cardBorderLight = Color(0xFFE5E3DC);
  static const Color cardBorderDark = Color(0xFF2F3235);

  // Typography & Neutrals
  static const Color textPrimaryLight = Color(0xFF242725);
  static const Color textSecondaryLight = Color(0xFF7A807B);
  static const Color textPrimaryDark = Color(0xFFF1F1EF);
  static const Color textSecondaryDark = Color(0xFFA1A5A1);
  static const Color neutralSlate = Color(0xFFCBD5E1);
  static const Color slateMuted = Color(0xFF9E9D89);

  // Primary Charcoal
  static const Color charcoal = Color(0xFF2A363B);
  static const Color charcoalLight = Color(0xFF3B484E);

  // Growth / Investments (Muted Sage Green)
  static const Color sage = Color(0xFF4D7266);
  static const Color sageLight = Color(0xFFE4ECE8);
  static const Color sageMuted = Color(0xFF8FA89B);

  // Outflow / Expenses / Caution (Muted Terracotta / Clay)
  static const Color terracotta = Color(0xFFBA4E3B);
  static const Color terracottaLight = Color(0xFFF9EBE8);
  static const Color terracottaMuted = Color(0xFFD48C70);
}

