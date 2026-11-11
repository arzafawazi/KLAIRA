import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/enums.dart';
import '../../shared/widgets/common.dart';
import '../result/widgets/result_widgets.dart';

/// Ilustrasi slide 1: kartu iklan dengan frasa yang ditandai.
class OverclaimAdIllustration extends StatelessWidget {
  const OverclaimAdIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    const ad = 'Hilangkan flek hitam 100% permanen hanya dalam 7 hari! Dijamin menyembuhkan jerawat.';
    TextSpan mark(String s) => TextSpan(
          text: s,
          style: const TextStyle(
            color: AppColors.danger,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.danger,
          ),
        );
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      AppCard(
        elevated: true,
        borderColor: null,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const IconTile(
                icon: Icons.auto_awesome, color: AppColors.accent600, background: AppColors.accent100, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Glowé Bright Serum', style: t.titleSmall),
                Text('Rp89.000 · Toko Resmi', style: t.bodySmall),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          Semantics(
            label: ad,
            child: Text.rich(
              TextSpan(style: t.bodyMedium, children: [
                const TextSpan(text: 'Hilangkan flek hitam '),
                mark('100% permanen'),
                const TextSpan(text: ' hanya dalam '),
                mark('7 hari'),
                const TextSpan(text: '! '),
                mark('Dijamin menyembuhkan'),
                const TextSpan(text: ' jerawat.'),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          const StatusBadge(category: OverclaimCategory.overclaim),
        ]),
      ),
      const SizedBox(height: 12),
      const _Chip(icon: Icons.warning_amber_rounded, color: AppColors.warn, text: '3 klaim berlebihan ditemukan'),
    ]);
  }
}

/// Ilustrasi slide 2: gauge skor + fitur.
class HowItWorksIllustration extends StatelessWidget {
  const HowItWorksIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    Widget row(String label, double v, Color c) => Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(children: [
            SizedBox(width: 92, child: Text(label, style: t.bodySmall?.copyWith(color: AppColors.ink700))),
            Expanded(child: LevelBar(value: v, color: c)),
          ]),
        );
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      AppCard(
        elevated: true,
        borderColor: null,
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const ScoreGauge(score: 86, size: 170),
          row('Kata absolut', 0.9, AppColors.danger),
          row('Klaim medis', 0.75, AppColors.danger),
          row('Superlatif', 0.5, AppColors.warn),
        ]),
      ),
      const SizedBox(height: 12),
      const _Chip(icon: Icons.auto_awesome, color: AppColors.primary600, text: 'Model Neurofuzzy · dapat dijelaskan'),
    ]);
  }
}

/// Ilustrasi slide 3: tile SDG 12.
class Sdg12Illustration extends StatelessWidget {
  const Sdg12Illustration({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 176,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          color: AppColors.accent500,
          borderRadius: AppRadius.lgAll,
          boxShadow: [
            BoxShadow(color: AppColors.accent600.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('12', style: t.displaySmall?.copyWith(color: AppColors.surface, fontSize: 40, height: 1.1)),
          const SizedBox(height: 4),
          Text('KONSUMSI DAN PRODUKSI YANG BERTANGGUNG JAWAB', style: t.labelSmall?.copyWith(color: AppColors.surface)),
          const SizedBox(height: 12),
          const Icon(Icons.eco_outlined, color: AppColors.surface, size: 26),
        ]),
      ),
      const SizedBox(height: 16),
      const Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          _Chip(icon: Icons.check_rounded, color: AppColors.safe, text: 'Info jujur'),
          _Chip(icon: Icons.check_rounded, color: AppColors.safe, text: 'Beli seperlunya'),
          _Chip(icon: Icons.check_rounded, color: AppColors.safe, text: 'Kurangi limbah'),
        ],
      ),
    ]);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.fullAll),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.ink700)),
        ]),
      );
}
