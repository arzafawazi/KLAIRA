import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Kategori hasil deteksi berdasarkan skor overclaim (0–100).
///
/// Batas kategori mengikuti proposal (Tabel 3.5):
/// Aman 0–39, Waspada 40–69, Overclaim 70–100.
enum OverclaimCategory {
  aman('aman', 'Aman', AppColors.safe, AppColors.safeBg, Icons.verified_user_outlined,
      'Klaim pada iklan ini tergolong wajar. Tetap cek nomor notifikasi BPOM sebelum membeli.'),
  waspada('waspada', 'Waspada', AppColors.warn, AppColors.warnBg, Icons.warning_amber_rounded,
      'Beberapa klaim perlu diwaspadai. Baca penjelasan di bawah sebelum memutuskan membeli.'),
  overclaim('overclaim', 'Overclaim', AppColors.danger, AppColors.dangerBg, Icons.cancel_outlined,
      'Iklan ini mengandung banyak klaim berlebihan. Pertimbangkan ulang sebelum membeli.');

  const OverclaimCategory(this.id, this.label, this.color, this.background, this.icon, this.summary);

  final String id;
  final String label;
  final Color color;
  final Color background;
  final IconData icon;
  final String summary;

  static const int waspadaThreshold = 40;
  static const int overclaimThreshold = 70;

  static OverclaimCategory fromScore(int score) {
    if (score >= overclaimThreshold) return OverclaimCategory.overclaim;
    if (score >= waspadaThreshold) return OverclaimCategory.waspada;
    return OverclaimCategory.aman;
  }

  static OverclaimCategory fromId(String id) =>
      values.firstWhere((e) => e.id == id, orElse: () => OverclaimCategory.aman);
}

/// Tingkat derajat keanggotaan fuzzy suatu fitur / frasa.
enum ClaimLevel {
  low('low', 'Rendah', AppColors.safe, AppColors.safeBg),
  medium('medium', 'Sedang', AppColors.warn, AppColors.warnBg),
  high('high', 'Tinggi', AppColors.danger, AppColors.dangerBg);

  const ClaimLevel(this.id, this.label, this.color, this.background);

  final String id;
  final String label;
  final Color color;
  final Color background;

  /// Label huruf kapital untuk dipakai di teks aturan fuzzy (RENDAH/SEDANG/TINGGI).
  String get fuzzyTerm => label.toUpperCase();

  static ClaimLevel fromMembership(double value) {
    if (value >= 0.65) return ClaimLevel.high;
    if (value >= 0.35) return ClaimLevel.medium;
    return ClaimLevel.low;
  }

  static ClaimLevel fromId(String id) => values.firstWhere((e) => e.id == id, orElse: () => ClaimLevel.low);
}

/// Sumber iklan / platform e-commerce.
enum AdSource {
  shopee('shopee', 'Shopee'),
  tokopedia('tokopedia', 'Tokopedia'),
  tiktokShop('tiktok_shop', 'TikTok Shop'),
  other('other', 'Lainnya');

  const AdSource(this.id, this.label);

  final String id;
  final String label;

  static AdSource fromId(String id) => values.firstWhere((e) => e.id == id, orElse: () => AdSource.other);

  /// Menebak platform dari URL produk.
  static AdSource fromUrl(String url) {
    final u = url.toLowerCase();
    if (u.contains('shopee')) return AdSource.shopee;
    if (u.contains('tokopedia')) return AdSource.tokopedia;
    if (u.contains('tiktok')) return AdSource.tiktokShop;
    return AdSource.other;
  }
}

/// Cara pengguna memasukkan iklan.
enum InputMode { text, link }
