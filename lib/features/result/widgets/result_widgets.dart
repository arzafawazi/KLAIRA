import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/analysis_result.dart';
import '../../../data/models/enums.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/visuals.dart';

/// Gauge setengah lingkaran skor 0–100 dengan animasi.
class ScoreGauge extends StatelessWidget {
  const ScoreGauge({super.key, required this.score, this.size = 220});

  final int score;
  final double size;

  @override
  Widget build(BuildContext context) {
    final category = OverclaimCategory.fromScore(score);
    final t = Theme.of(context).textTheme;
    return Semantics(
      label: 'Skor overclaim $score dari 100, kategori ${category.label}',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: score.toDouble()),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => SizedBox(
          width: size,
          height: size * 0.56,
          child: CustomPaint(
            painter: _GaugePainter(value: v / 100, color: category.color),
            child: Align(
              alignment: const Alignment(0, 0.75),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${v.round()}', style: t.displaySmall?.copyWith(fontSize: 44, height: 1.05)),
                Text('dari 100', style: t.bodySmall),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({required this.value, required this.color});
  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.08;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.width - stroke);
    final base = Paint()
      ..color = AppColors.ink100
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi, math.pi, false, base);
    if (value > 0) {
      canvas.drawArc(rect, math.pi, math.pi * value, false, base..color = color);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.value != value || old.color != color;
}

/// Legenda skala kategori di bawah gauge.
class ScaleLegend extends StatelessWidget {
  const ScaleLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme.bodySmall;
    Widget seg(int flex, Color c) => Expanded(
        flex: flex, child: Container(height: 6, decoration: BoxDecoration(color: c, borderRadius: AppRadius.fullAll)));
    return Column(children: [
      Row(children: [
        seg(40, AppColors.safe),
        const SizedBox(width: 4),
        seg(30, AppColors.warn),
        const SizedBox(width: 4),
        seg(30, AppColors.danger),
      ]),
      const SizedBox(height: 6),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('0–39 Aman', style: t),
        Text('40–69 Waspada', style: t),
        Text('70–100 Overclaim', style: t),
      ]),
    ]);
  }
}

/// Teks iklan dengan frasa bermasalah ditandai (warna + tebal + garis bawah).
/// Frasa bisa diketuk untuk membuka penjelasannya.
class HighlightedAdText extends StatefulWidget {
  const HighlightedAdText({super.key, required this.text, required this.phrases, this.onPhraseTap});

  final String text;
  final List<FlaggedPhrase> phrases;
  final ValueChanged<FlaggedPhrase>? onPhraseTap;

  @override
  State<HighlightedAdText> createState() => _HighlightedAdTextState();
}

class _HighlightedAdTextState extends State<HighlightedAdText> {
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();

    final base = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.65);
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final p in widget.phrases) {
      if (p.start < cursor || p.end > widget.text.length) continue;
      if (p.start > cursor) spans.add(TextSpan(text: widget.text.substring(cursor, p.start)));
      final rec = TapGestureRecognizer()..onTap = () => widget.onPhraseTap?.call(p);
      _recognizers.add(rec);
      spans.add(TextSpan(
        text: widget.text.substring(p.start, p.end),
        recognizer: widget.onPhraseTap == null ? null : rec,
        style: TextStyle(
          color: p.level.color,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
          decorationColor: p.level.color,
          backgroundColor: p.level.background.withValues(alpha: 0.6),
        ),
      ));
      cursor = p.end;
    }
    if (cursor < widget.text.length) spans.add(TextSpan(text: widget.text.substring(cursor)));
    // RichText: satu paragraf dengan banyak gaya (frasa bermasalah diwarnai & bisa diketuk).
    return RichText(
      textScaler: MediaQuery.textScalerOf(context),
      text: TextSpan(style: base, children: spans),
    );
  }
}

/// Baris fitur tekstual + derajat keanggotaan.
class FeatureRow extends StatelessWidget {
  const FeatureRow({super.key, required this.feature, this.onTap, this.showDivider = true});

  final TextualFeature feature;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final l = feature.level;
    final examples =
        feature.matches.isEmpty ? 'Tidak ditemukan pada teks' : feature.matches.take(4).map((m) => '“$m”').join(', ');
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: showDivider ? const Border(bottom: BorderSide(color: AppColors.ink100)) : null,
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IconTile(icon: Visuals.featureIcon(feature.id), color: l.color, background: l.background, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(feature.label, style: t.titleSmall)),
                Text('${l.label} · ${Fmt.decimal(feature.membership)}',
                    style: t.bodySmall?.copyWith(color: l.color, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 4),
              Text(examples, style: t.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              LevelBar(value: feature.membership, color: l.color),
            ]),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 4),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(Icons.chevron_right_rounded, color: AppColors.ink300, size: 20),
            ),
          ],
        ]),
      ),
    );
  }
}

/// Kartu aturan fuzzy "JIKA … MAKA …" dengan kata kunci berwarna.
class RuleCard extends StatelessWidget {
  const RuleCard({super.key, required this.rule});

  final FuzzyRule rule;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final color = rule.outputLevel.color;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Pill(label: 'Aturan ${rule.id}'),
          const Spacer(),
          Text('Kekuatan ${Fmt.decimal(rule.strength)}',
              style: t.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 10),
        Text.rich(TextSpan(style: t.bodyMedium, children: _spans(rule.text))),
        const SizedBox(height: 10),
        LevelBar(value: rule.strength, color: color),
      ]),
    );
  }

  static List<TextSpan> _spans(String text) {
    const keys = {
      'JIKA': AppColors.primary600,
      'DAN': AppColors.primary600,
      'MAKA': AppColors.primary600,
      'TINGGI': AppColors.danger,
      'SEDANG': AppColors.warn,
      'RENDAH': AppColors.safe,
    };
    return text.split(' ').expand((w) sync* {
      final c = keys[w];
      yield TextSpan(
        text: w,
        style: c == null ? null : TextStyle(color: c, fontWeight: FontWeight.w700),
      );
      yield const TextSpan(text: ' ');
    }).toList();
  }
}

/// Grafik fungsi keanggotaan RENDAH–SEDANG–TINGGI dengan penanda nilai μ.
class MembershipChart extends StatelessWidget {
  const MembershipChart({super.key, required this.value, this.height = 110});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme.bodySmall;
    return Semantics(
      label: 'Grafik derajat keanggotaan, nilai ${Fmt.decimal(value)}',
      child: Column(children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(painter: _MembershipPainter(value)),
        ),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Rendah', style: t?.copyWith(color: AppColors.safe)),
          Text('Sedang', style: t?.copyWith(color: AppColors.warn)),
          Text('Tinggi', style: t?.copyWith(color: AppColors.danger)),
        ]),
      ]),
    );
  }
}

class _MembershipPainter extends CustomPainter {
  const _MembershipPainter(this.value);
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height - 8, top = 6.0;
    Offset p(double x, double y) => Offset(x * w, top + (1 - y) * (h - top));
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;
    void poly(List<Offset> pts, Color c) {
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final o in pts.skip(1)) {
        path.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(path, line..color = c);
    }

    // Sama dengan fungsi keanggotaan pada OverclaimSimulator.
    poly([p(0, 1), p(0.2, 1), p(0.45, 0)], AppColors.safe);
    poly([p(0.25, 0), p(0.5, 1), p(0.75, 0)], AppColors.warn);
    poly([p(0.55, 0), p(0.8, 1), p(1, 1)], AppColors.danger);
    canvas.drawLine(p(0, 0), p(1, 0), Paint()..color = AppColors.ink200);

    // Penanda nilai.
    final x = value.clamp(0.0, 1.0);
    final dash = Paint()
      ..color = AppColors.ink900
      ..strokeWidth = 1.5;
    for (double y = top; y < h; y += 8) {
      canvas.drawLine(Offset(x * w, y), Offset(x * w, math.min(y + 4, h)), dash);
    }
    final level = ClaimLevel.fromMembership(x);
    canvas.drawCircle(Offset(x * w, top + 2), 6, Paint()..color = AppColors.surface);
    canvas.drawCircle(Offset(x * w, top + 2), 4.5, Paint()..color = level.color);
  }

  @override
  bool shouldRepaint(_MembershipPainter old) => old.value != value;
}
