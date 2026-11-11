import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/analysis_result.dart';
import '../../data/models/content.dart';
import '../../data/repositories/content_repository.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/visuals.dart';
import '../../state/app_state.dart';
import 'widgets/result_widgets.dart';
import '../../core/utils/responsive.dart';

/// 10 Detail Klaim — penjelasan satu fitur tekstual pada satu hasil analisis.
class ClaimDetailScreen extends StatelessWidget {
  const ClaimDetailScreen({super.key, required this.resultId, required this.featureId});

  final String resultId;
  final String featureId;

  @override
  Widget build(BuildContext context) {
    final result = context.select<AppState, AnalysisResult?>((s) => s.byId(resultId));
    final feature = result?.featureById(featureId);
    final insight = context.read<ContentRepository>().insightFor(featureId);
    if (result == null || feature == null || insight == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.help_outline_rounded,
          title: 'Detail tidak tersedia',
          message: 'Data klaim untuk hasil ini tidak ditemukan.',
        ),
      );
    }

    final t = Theme.of(context).textTheme;
    final l = feature.level;
    final phrase = result.flaggedPhrases.where((p) => p.featureId == featureId).firstOrNull;
    final quote = phrase?.text ?? (feature.matches.isNotEmpty ? feature.matches.first : null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Klaim'),
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
              child: CircleIconButton(
                  icon: Icons.arrow_back_rounded, tooltip: 'Kembali', size: 40, onPressed: () => context.pop())),
        ),
      ),
      body: ResponsiveCenter(
          child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Wrap(spacing: 8, runSpacing: 8, children: [
            Pill(label: insight.title, color: l.color, background: l.background, icon: Visuals.featureIcon(featureId)),
            Pill(label: 'Tingkat: ${l.label}', color: AppColors.ink700, outlined: true),
          ]),
          const SizedBox(height: 16),

          // ---- Kutipan
          ClipRRect(
            borderRadius: AppRadius.lgAll,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(left: BorderSide(color: l.color, width: 4)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 18, 18, 18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.format_quote_rounded, color: l.color, size: 26),
                const SizedBox(height: 6),
                Text(quote == null ? 'Tidak ada frasa pada kategori ini' : '“${_capitalize(quote)}”',
                    style: t.titleLarge),
                const SizedBox(height: 8),
                Text(
                  quote == null
                      ? 'Teks iklan tidak memuat pola ${insight.shortTitle.toLowerCase()}.'
                      : 'Ditemukan pada deskripsi “${result.product}”',
                  style: t.bodySmall,
                ),
              ]),
            ),
          ),
          const SizedBox(height: AppSpacing.section),

          _Section(title: 'Kenapa ini bermasalah?', child: Text(insight.why, style: t.bodyMedium)),

          // ---- Grafik keanggotaan
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text('Derajat keanggotaan fitur', style: t.titleSmall)),
                Text('μ = ${Fmt.decimal(feature.membership)}', style: t.titleSmall?.copyWith(color: l.color)),
              ]),
              const SizedBox(height: 12),
              MembershipChart(value: feature.membership),
              const SizedBox(height: 10),
              Text(
                'Nilai ${Fmt.decimal(feature.membership)} berada pada himpunan ${l.fuzzyTerm} untuk fitur ${insight.shortTitle.toLowerCase()}.',
                style: t.bodySmall,
              ),
            ]),
          ),
          const SizedBox(height: AppSpacing.section),

          _Section(
            title: 'Kata pemicu',
            caption: feature.matches.isEmpty ? 'Contoh kata pemicu pada kategori ini' : null,
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              if (feature.matches.isEmpty)
                for (final e in insight.examples) Pill(label: e, color: AppColors.ink700, background: AppColors.ink100)
              else
                for (final m in feature.matches) Pill(label: m, color: l.color, background: l.background),
            ]),
          ),

          _Section(
            title: 'Contoh klaim yang lebih wajar',
            child: AppCard(
              color: AppColors.safeBg,
              borderColor: null,
              child: Column(children: [
                for (final (i, s) in insight.betterClaims.indexed)
                  Padding(
                    padding: EdgeInsets.only(bottom: i == insight.betterClaims.length - 1 ? 0 : 12),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Icon(Icons.check_rounded, size: 18, color: AppColors.safe),
                      const SizedBox(width: 10),
                      Expanded(child: Text(s, style: t.bodyMedium)),
                    ]),
                  ),
              ]),
            ),
          ),

          _ReferenceCard(insight: insight),
        ],
      )),
      bottomNavigationBar: BottomActionBar(
        child: OutlinedButton.icon(
          onPressed: () => context.push(AppRoutes.article('enam-jenis-klaim')),
          icon: const Icon(Icons.menu_book_outlined, size: 20),
          label: const Text('Pelajari Jenis Klaim Lain'),
        ),
      ),
    );
  }

  static String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.caption});
  final String title;
  final Widget child;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.section),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: t.titleMedium),
        if (caption != null) Text(caption!, style: t.bodySmall),
        const SizedBox(height: 8),
        child,
      ]),
    );
  }
}

class _ReferenceCard extends StatelessWidget {
  const _ReferenceCard({required this.insight});
  final ClaimInsight insight;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final parts = insight.reference.split(' — ');
    return AppCard(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const IconTile(icon: Icons.balance_rounded),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('DASAR ACUAN', style: t.labelSmall),
            const SizedBox(height: 2),
            Text(parts.first, style: t.titleSmall),
            if (parts.length > 1) ...[
              const SizedBox(height: 4),
              Text(parts.sublist(1).join(' — '), style: t.bodySmall)
            ],
          ]),
        ),
      ]),
    );
  }
}
