import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/content.dart';
import '../../data/repositories/content_repository.dart';
import '../../shared/widgets/article_cover.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/visuals.dart';

/// 12 Edukasi — konten unggulan SDG 12, kamus klaim, dan artikel.
class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  String? _category;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final content = context.read<ContentRepository>();
    final featured = content.featuredArticle;
    final articles =
        content.articles.where((a) => !a.featured && (_category == null || a.category == _category)).toList();

    // Jumlah kolom grid menyesuaikan lebar layar.
    final glossaryColumns = context.gridColumns(compact: 2, medium: 3, expanded: 6);

    return Scaffold(
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 1040,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text('Edukasi', style: t.headlineSmall),
              Text('Kenali klaim, belanja lebih bijak', style: t.bodyMedium?.copyWith(color: AppColors.ink500)),
              const SizedBox(height: 20),
              if (featured != null) _FeaturedCard(article: featured),
              const SizedBox(height: AppSpacing.section),
              const SectionHeader(title: 'Kamus Klaim', subtitle: 'Enam pola klaim berlebihan yang dianalisis'),
              const SizedBox(height: 12),
              GridView.builder(
                key: const Key('glossary-grid'),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: content.insights.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: glossaryColumns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 138,
                ),
                itemBuilder: (_, i) => _GlossaryCard(insight: content.insights[i]),
              ),
              const SizedBox(height: AppSpacing.section),
              const SectionHeader(title: 'Artikel'),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                ChoiceChip(
                    label: const Text('Semua'),
                    selected: _category == null,
                    onSelected: (_) => setState(() => _category = null)),
                for (final c in content.articleCategories)
                  ChoiceChip(
                      label: Text(c), selected: _category == c, onSelected: (_) => setState(() => _category = c)),
              ]),
              const SizedBox(height: 16),
              // Artikel: 1 kolom di HP, 2 kolom di tablet (lebar maks. tiap kartu 520 dp).
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: articles.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 520,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 112,
                ),
                itemBuilder: (_, i) => _ArticleTile(article: articles[i]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.article});
  final Article article;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Material(
      color: AppColors.accent500,
      borderRadius: AppRadius.xlAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.article(article.id)),
        child: Stack(children: [
          Positioned(
            right: -6,
            bottom: -28,
            child: Text('12',
                style: t.displaySmall
                    ?.copyWith(fontSize: 120, color: AppColors.surface.withValues(alpha: 0.18), height: 1)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.eco_outlined, size: 14, color: AppColors.surface),
                const SizedBox(width: 6),
                Text('SDG 12 · KONSUMSI BERTANGGUNG JAWAB', style: t.labelSmall?.copyWith(color: AppColors.surface)),
              ]),
              const SizedBox(height: 10),
              SizedBox(
                width: 230,
                child: Text(article.title, style: t.titleLarge?.copyWith(color: AppColors.surface)),
              ),
              const SizedBox(height: 10),
              Row(children: [
                Text('Baca · ${article.readMinutes} menit',
                    style: t.bodySmall?.copyWith(color: AppColors.surface.withValues(alpha: 0.9))),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.surface),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _GlossaryCard extends StatelessWidget {
  const _GlossaryCard({required this.insight});
  final ClaimInsight insight;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final high = insight.featureId == 'absolute_words' || insight.featureId == 'medical_claim';
    final color = high ? AppColors.danger : AppColors.warn;
    final bg = high ? AppColors.dangerBg : AppColors.warnBg;
    return SizedBox(
      child: AppCard(
        padding: const EdgeInsets.all(14),
        onTap: () => showInsightSheet(context, insight),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IconTile(icon: Visuals.featureIcon(insight.featureId), color: color, background: bg, size: 36),
          const SizedBox(height: 10),
          Text(insight.shortTitle, style: t.titleSmall, maxLines: 2),
          const Spacer(),
          Text(insight.examples.first, style: t.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

/// Bottom sheet penjelasan satu kategori klaim.
Future<void> showInsightSheet(BuildContext context, ClaimInsight insight) {
  final t = Theme.of(context).textTheme;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        children: [
          Text(insight.title, style: t.titleLarge),
          const SizedBox(height: 4),
          Text(insight.description, style: t.bodyMedium?.copyWith(color: AppColors.ink500)),
          const SizedBox(height: 16),
          Text('Kenapa perlu diwaspadai?', style: t.titleSmall),
          const SizedBox(height: 4),
          Text(insight.why, style: t.bodyMedium),
          const SizedBox(height: 16),
          Text('Contoh frasa', style: t.titleSmall),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final e in insight.examples) Pill(label: e, color: AppColors.danger, background: AppColors.dangerBg),
          ]),
          const SizedBox(height: 16),
          Text('Alternatif yang lebih wajar', style: t.titleSmall),
          const SizedBox(height: 8),
          for (final b in insight.betterClaims)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.check_rounded, size: 18, color: AppColors.safe),
                const SizedBox(width: 8),
                Expanded(child: Text(b, style: t.bodyMedium)),
              ]),
            ),
          const SizedBox(height: 8),
          InfoBanner(text: insight.reference, icon: Icons.balance_rounded),
        ],
      ),
    ),
  );
}

class _ArticleTile extends StatelessWidget {
  const _ArticleTile({required this.article});
  final Article article;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => context.push(AppRoutes.article(article.id)),
      child: Row(children: [
        SizedBox(
          width: 80,
          height: 80,
          child: ArticleCover(article: article, borderRadius: AppRadius.mdAll),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(article.category.toUpperCase(), style: t.labelSmall?.copyWith(color: AppColors.primary600)),
            const SizedBox(height: 4),
            Text(article.title, style: t.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text('${article.readMinutes} menit baca', style: t.bodySmall),
          ]),
        ),
      ]),
    );
  }
}
