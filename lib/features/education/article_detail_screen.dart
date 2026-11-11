import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/content.dart';
import '../../data/repositories/content_repository.dart';
import '../../core/utils/responsive.dart';
import '../../shared/widgets/article_cover.dart';
import '../../shared/widgets/common.dart';

/// 13 Detail Artikel.
class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key, required this.articleId});

  final String articleId;

  @override
  Widget build(BuildContext context) {
    final article = context.read<ContentRepository>().articleById(articleId);
    final back = Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Center(
          child: CircleIconButton(
              icon: Icons.arrow_back_rounded, tooltip: 'Kembali', size: 40, onPressed: () => context.pop())),
    );
    if (article == null) {
      return Scaffold(
        appBar: AppBar(leading: back, leadingWidth: 64),
        body: const EmptyState(
            icon: Icons.article_outlined, title: 'Artikel tidak ditemukan', message: 'Coba buka artikel lain.'),
      );
    }
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artikel'),
        leading: back,
        leadingWidth: 64,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleIconButton(
              icon: Icons.bookmark_border_rounded,
              tooltip: 'Simpan artikel',
              size: 40,
              onPressed: () => ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Artikel ditandai untuk dibaca nanti.'))),
            ),
          ),
        ],
      ),
      body: ResponsiveCenter(
          child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          ArticleCover(article: article, height: context.isLandscape ? 140 : 190, borderRadius: AppRadius.xlAll),
          const SizedBox(height: 16),
          Row(children: [
            Pill(label: article.category),
            const SizedBox(width: 8),
            Text('${article.readMinutes} menit baca · Tim Klaira', style: t.bodySmall),
          ]),
          const SizedBox(height: 12),
          Text(article.title, style: t.headlineSmall),
          const SizedBox(height: 12),
          Text(article.summary, style: t.bodyLarge?.copyWith(color: AppColors.ink500)),
          const SizedBox(height: AppSpacing.lg),
          for (final b in article.blocks) _Block(block: b),
          if (article.id == 'enam-jenis-klaim')
            const InfoBanner(
              icon: Icons.auto_awesome,
              color: AppColors.accent600,
              background: AppColors.accent100,
              text: 'Keenam pola ini menjadi fitur tekstual yang dianalisis model neurofuzzy di Klaira.',
            ),
        ],
      )),
      bottomNavigationBar: BottomActionBar(
        child: FilledButton.icon(
          onPressed: () => context.push(AppRoutes.check),
          icon: const Icon(Icons.document_scanner_outlined, size: 20),
          label: const Text('Coba Cek Iklan'),
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.block});
  final ArticleBlock block;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    if (!block.isList) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(block.text!, style: t.bodyLarge),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (block.heading != null) ...[Text(block.heading!, style: t.titleMedium), const SizedBox(height: 12)],
        for (final (i, item) in block.items.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary600,
                child: Text('${i + 1}', style: t.bodySmall?.copyWith(color: AppColors.surface)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.title, style: t.titleSmall),
                  const SizedBox(height: 2),
                  Text(item.body, style: t.bodyMedium),
                ]),
              ),
            ]),
          ),
      ]),
    );
  }
}
