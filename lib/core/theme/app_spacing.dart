import 'package:flutter/widgets.dart';

/// Token jarak (kelipatan 4 px) sesuai variabel Figma `space/*`.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Padding horizontal standar setiap layar.
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: lg);

  /// Jarak vertikal antarsection pada satu layar.
  static const double section = xxl;
}

/// Token radius sesuai variabel Figma `radius/*`.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;

  static final BorderRadius smAll = BorderRadius.circular(sm);
  static final BorderRadius mdAll = BorderRadius.circular(md);
  static final BorderRadius lgAll = BorderRadius.circular(lg);
  static final BorderRadius xlAll = BorderRadius.circular(xl);
  static final BorderRadius fullAll = BorderRadius.circular(full);
}
