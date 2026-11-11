import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/analysis_result.dart';
import '../../shared/widgets/common.dart';
import '../../state/app_state.dart';
import 'widgets/result_widgets.dart';

/// 09 Hasil Analisis.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.resultId});

  final String resultId;

  @override
  Widget build(BuildContext context) {
    final result = context.select<AppState, AnalysisResult?>((s) => s.byId(resultId));
    if (result == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Hasil tidak ditemukan',
          message: 'Hasil analisis ini mungkin sudah dihapus dari riwayat.',
          action: FilledButton(onPressed: () => context.go(AppRoutes.home), child: const Text('Ke Beranda')),
        ),
      );
    }
    final t = Theme.of(context).textTheme;
    final c = result.category;
    void openFeature(String featureId) => context.push(AppRoutes.claim(result.id, featureId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Analisis'),
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: CircleIconButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Kembali',
              size: 40,
              onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.home),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleIconButton(
              icon: Icons.share_outlined,
              tooltip: 'Bagikan ringkasan',
              size: 40,
              onPressed: () => _share(context, result),
            ),
          ),
        ],
      ),
      // Responsif: satu kolom di HP; dua kolom berdampingan di layar lebar (≥ 840 dp).
      body: LayoutBuilder(builder: (context, constraints) {
        final left = <Widget>[
          // ---- Produk
          Row(children: [
            const IconTile(
                icon: Icons.auto_awesome, color: AppColors.accent600, background: AppColors.accent100, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(result.product, style: t.titleMedium),
                Text('${result.source.label} · ${Fmt.full(result.analyzedAt)}', style: t.bodySmall),
              ]),
            ),
          ]),
          const SizedBox(height: AppSpacing.section),

          // ---- Skor
          AppCard(
            elevated: true,
            radius: AppRadius.xl,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(children: [
              ScoreGauge(score: result.score),
              const SizedBox(height: 12),
              StatusBadge(category: c, large: true),
              const SizedBox(height: 12),
              Text(c.summary, style: t.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const ScaleLegend(),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(children: [
                _Metric(value: Fmt.percent(result.confidence), label: 'Keyakinan model'),
                _Metric(value: '${result.flaggedPhrases.length}', label: 'Frasa ditandai'),
                _Metric(value: '${result.activeFeatureCount} / ${result.features.length}', label: 'Fitur aktif'),
              ]),
            ]),
          ),
          const SizedBox(height: AppSpacing.section),

          // ---- Frasa ditandai
          SectionHeader(
            title: 'Klaim yang Ditandai',
            subtitle: result.flaggedPhrases.isEmpty
                ? 'Tidak ada frasa berlebihan yang terdeteksi'
                : 'Ketuk frasa bertanda untuk melihat penjelasannya',
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              HighlightedAdText(
                text: result.inputText,
                phrases: result.flaggedPhrases,
                onPhraseTap: (p) => openFeature(p.featureId),
              ),
              if (result.flaggedPhrases.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Wrap(spacing: 16, children: [
                  _LegendDot(color: AppColors.danger, label: 'Tingkat tinggi'),
                  _LegendDot(color: AppColors.warn, label: 'Tingkat sedang'),
                ]),
              ],
            ]),
          ),
          const SizedBox(height: AppSpacing.section),
        ];
        final right = <Widget>[
          // ---- Fitur tekstual
          const SectionHeader(
            title: 'Fitur Tekstual Terdeteksi',
            subtitle: 'Input untuk model neurofuzzy (derajat keanggotaan 0–1)',
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(children: [
              for (final (i, f) in result.featuresSorted.indexed)
                FeatureRow(
                  feature: f,
                  showDivider: i < result.features.length - 1,
                  onTap: () => openFeature(f.id),
                ),
            ]),
          ),
          const SizedBox(height: AppSpacing.section),

          // ---- Penjelasan aturan
          SectionHeader(
            title: 'Mengapa skornya ${result.score}?',
            subtitle: 'Aturan fuzzy yang paling berpengaruh pada hasil',
            icon: Icons.auto_awesome,
          ),
          const SizedBox(height: 12),
          for (final r in result.rules) ...[RuleCard(rule: r), const SizedBox(height: 12)],
          const SizedBox(height: 12),

          // ---- Langkah bijak
          const SectionHeader(title: 'Langkah Bijak Sebelum Membeli', icon: Icons.eco_outlined),
          const SizedBox(height: 12),
          const AppCard(
            color: AppColors.safeBg,
            borderColor: null,
            child: Column(children: [
              _Check('Cek nomor notifikasi BPOM di cekbpom.pom.go.id'),
              _Check('Bandingkan dengan produk sejenis yang klaimnya wajar'),
              _Check('Baca ulasan pembeli yang menyertakan foto asli'),
              _Check('Beli sesuai kebutuhan, bukan karena janji hasil instan', last: true),
            ]),
          ),
          const SizedBox(height: 16),
          InfoBanner(
            text: result.disclaimer,
            color: AppColors.ink700,
            background: AppColors.ink100,
          ),
        ];
        const padding = EdgeInsets.fromLTRB(16, 8, 16, 24);
        if (constraints.maxWidth >= WindowSize.expandedMin) {
          return ResponsiveCenter(
            maxWidth: ResponsiveCenter.wide,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: left)),
                const SizedBox(width: 24),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: right)),
              ]),
            ),
          );
        }
        return ResponsiveCenter(child: ListView(padding: padding, children: [...left, ...right]));
      }),
      bottomNavigationBar: BottomActionBar(
        child: Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              key: const Key('save-button'),
              onPressed: () {
                context.read<AppState>().toggleSaved(result.id);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(result.saved ? 'Dihapus dari tersimpan' : 'Hasil disimpan'),
                  duration: const Duration(seconds: 2),
                ));
              },
              icon: Icon(result.saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, size: 20),
              label: Text(result.saved ? 'Tersimpan' : 'Simpan'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => context.pushReplacement(AppRoutes.check),
              icon: const Icon(Icons.document_scanner_outlined, size: 20),
              label: const Text('Cek Lagi'),
            ),
          ),
        ]),
      ),
    );
  }

  static void _share(BuildContext context, AnalysisResult r) {
    final top =
        r.featuresSorted.where((f) => f.isActive).take(3).map((f) => '• ${f.label} (${f.level.label})').join('\n');
    final text = 'Hasil cek Klaira untuk "${r.product}"\n'
        'Skor overclaim: ${r.score}/100 — ${r.category.label}\n'
        '${top.isEmpty ? '' : 'Temuan utama:\n$top\n'}'
        '${r.disclaimer}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Ringkasan hasil disalin. Tempel untuk membagikan.')));
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Expanded(
      child: Column(children: [
        Text(value, style: t.titleMedium),
        Text(label, style: t.bodySmall, textAlign: TextAlign.center),
      ]),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ]);
}

class _Check extends StatelessWidget {
  const _Check(this.text, {this.last = false});
  final String text;
  final bool last;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: last ? 0 : 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.check_rounded, size: 18, color: AppColors.safe),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ]),
      );
}
