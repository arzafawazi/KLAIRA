import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/simulation/overclaim_lexicon.dart';

/// Pemetaan ikon & warna untuk fitur klaim dan artikel.
abstract final class Visuals {
  static IconData featureIcon(String featureId) => switch (featureId) {
        ClaimFeatureId.absolute => Icons.warning_amber_rounded,
        ClaimFeatureId.medical => Icons.medical_services_outlined,
        ClaimFeatureId.time => Icons.schedule_rounded,
        ClaimFeatureId.authority => Icons.balance_rounded,
        ClaimFeatureId.superlative => Icons.auto_awesome_outlined,
        ClaimFeatureId.emotional => Icons.campaign_outlined,
        _ => Icons.info_outline,
      };

  static IconData articleIcon(String name) => switch (name) {
        'leaf' => Icons.eco_outlined,
        'file' => Icons.description_outlined,
        'shield' => Icons.verified_user_outlined,
        'scale' => Icons.balance_rounded,
        'search' => Icons.manage_search_rounded,
        _ => Icons.menu_book_outlined,
      };

  /// (warna ikon, warna latar) untuk tone artikel.
  static (Color, Color) tone(String tone) => switch (tone) {
        'safe' => (AppColors.safe, AppColors.safeBg),
        'accent' => (AppColors.accent600, AppColors.accent100),
        _ => (AppColors.primary600, AppColors.primary50),
      };
}
