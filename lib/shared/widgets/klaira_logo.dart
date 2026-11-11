import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum LogoVariant { accent, primary, light }

/// Logo mark Klaira: kaca pembesar + centang = "cek klaim".
/// Sesuai komponen Figma `Brand/Logo Mark`.
class KlairaLogo extends StatelessWidget {
  const KlairaLogo({super.key, this.size = 64, this.variant = LogoVariant.primary});

  final double size;
  final LogoVariant variant;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (variant) {
      LogoVariant.accent => (AppColors.accent500, AppColors.surface),
      LogoVariant.primary => (AppColors.primary600, AppColors.surface),
      LogoVariant.light => (AppColors.surface, AppColors.primary600),
    };
    return Semantics(
      label: 'Logo Klaira',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(size * 0.28)),
        alignment: Alignment.center,
        child: CustomPaint(size: Size.square(size * 0.56), painter: _MarkPainter(fg)),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 32;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawCircle(Offset(14 * s, 14 * s), 9.5 * s, p);
    canvas.drawLine(Offset(21 * s, 21 * s), Offset(28 * s, 28 * s), p);
    final check = Path()
      ..moveTo(9.5 * s, 14.2 * s)
      ..lineTo(12.5 * s, 17.2 * s)
      ..lineTo(18 * s, 11 * s);
    canvas.drawPath(check, p);
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.color != color;
}
