import 'package:flutter/widgets.dart';

/// Kelas ukuran jendela mengikuti panduan Material 3 (window size classes).
///
/// | Kelas      | Lebar        | Contoh perangkat                  |
/// |------------|--------------|-----------------------------------|
/// | compact    | < 600 dp     | HP potret                         |
/// | medium     | 600–839 dp   | HP lanskap, tablet kecil, foldable|
/// | expanded   | ≥ 840 dp     | tablet lanskap, desktop           |
enum WindowSize {
  compact,
  medium,
  expanded;

  static const double mediumMin = 600;
  static const double expandedMin = 840;

  static WindowSize fromWidth(double width) {
    if (width >= expandedMin) return WindowSize.expanded;
    if (width >= mediumMin) return WindowSize.medium;
    return WindowSize.compact;
  }

  bool get isCompact => this == WindowSize.compact;
  bool get isExpanded => this == WindowSize.expanded;
}

/// Akses cepat informasi layar dari [BuildContext].
extension ResponsiveContext on BuildContext {
  /// Kelas ukuran berdasarkan lebar layar (bukan lebar widget induk).
  WindowSize get windowSize => WindowSize.fromWidth(MediaQuery.sizeOf(this).width);

  bool get isLandscape => MediaQuery.orientationOf(this) == Orientation.landscape;

  /// Jumlah kolom grid yang disarankan untuk lebar layar saat ini.
  int gridColumns({int compact = 2, int medium = 3, int expanded = 4}) => switch (windowSize) {
        WindowSize.compact => compact,
        WindowSize.medium => medium,
        WindowSize.expanded => expanded,
      };
}

/// Membatasi lebar konten agar tetap nyaman dibaca di tablet/desktop
/// (baris teks tidak terlalu panjang) dan memusatkannya.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({super.key, required this.child, this.maxWidth = 720});

  final Widget child;
  final double maxWidth;

  /// Lebar maksimum konten untuk layar dua kolom (mis. Hasil Analisis).
  static const double wide = 1120;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
      );
}
