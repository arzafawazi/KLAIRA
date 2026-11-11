import 'package:flutter/material.dart';

/// Token warna Klaira.
///
/// Nilai diambil 1:1 dari koleksi variabel Figma **"Klaira Tokens"**
/// (halaman 🎨 Design System). Jika warna di Figma diubah, ubah juga di sini
/// agar desain dan kode tetap sinkron.
abstract final class AppColors {
  // Primary — identitas aplikasi, tombol utama, navigasi aktif.
  static const primary700 = Color(0xFF0B4A44);
  static const primary600 = Color(0xFF0F5C55);
  static const primary500 = Color(0xFF177A70);
  static const primary100 = Color(0xFFD7ECE8);
  static const primary50 = Color(0xFFEDF6F4);

  // Accent — mengikuti warna resmi SDG 12, dipakai untuk konten edukasi.
  static const accent600 = Color(0xFFA9771F);
  static const accent500 = Color(0xFFBF8B2E);
  static const accent100 = Color(0xFFF6EBD6);

  // Ink / Neutral — teks dan garis.
  static const ink900 = Color(0xFF14211F);
  static const ink700 = Color(0xFF3A4A47);
  static const ink500 = Color(0xFF66756F);
  static const ink300 = Color(0xFFB4BFBC);
  static const ink200 = Color(0xFFDCE2E0);
  static const ink100 = Color(0xFFECEFEE);

  // Surface.
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF6F5F1);

  // Status — tiga kategori hasil deteksi.
  static const safe = Color(0xFF1E8E5A);
  static const safeBg = Color(0xFFE2F3E9);
  static const warn = Color(0xFFB86E00);
  static const warnBg = Color(0xFFFDF0DA);
  static const danger = Color(0xFFC8372D);
  static const dangerBg = Color(0xFFFBE4E1);
}
