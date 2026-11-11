import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/content.dart';
import '../../data/models/enums.dart';
import '../../data/repositories/content_repository.dart';
import '../../shared/widgets/article_cover.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/history_card.dart';
import '../../state/app_state.dart';

/// 05 Beranda.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final state = context.watch<AppState>();
    final content = context.read<ContentRepository>();
    final recent = state.recent(2);
    final firstName = state.userName.split(' ').first;

    return Scaffold(
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 960,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(children: [
                UserAvatar(initials: state.initials),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(Fmt.greeting(), style: t.bodyMedium?.copyWith(color: AppColors.ink500)),
                    GreetingText(name: firstName),
                  ]),
                ),
                CircleIconButton(
                  icon: Icons.notifications_none_rounded,
                  tooltip: 'Notifikasi',
                  onPressed: () => ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Belum ada notifikasi baru.'))),
                ),
              ]),
              const SizedBox(height: 20),
              const _HeroCard(),
              const SizedBox(height: AppSpacing.section),
              Row(children: [
                _StatTile(
                    icon: Icons.search_rounded,
                    value: state.totalChecked,
                    label: 'Iklan dicek',
                    color: AppColors.ink900),
                const SizedBox(width: 12),
                _StatTile(
                    icon: OverclaimCategory.overclaim.icon,
                    value: state.countOf(OverclaimCategory.overclaim),
                    label: 'Overclaim',
                    color: AppColors.danger),
                const SizedBox(width: 12),
                _StatTile(
                    icon: OverclaimCategory.aman.icon,
                    value: state.countOf(OverclaimCategory.aman),
                    label: 'Aman',
                    color: AppColors.safe),
              ]),
              const SizedBox(height: AppSpacing.section),
              SectionHeader(
                title: 'Riwayat Terakhir',
                actionLabel: 'Lihat semua',
                onAction: () => context.go(AppRoutes.history),
              ),
              const SizedBox(height: 8),
              if (recent.isEmpty)
                AppCard(
                  child: Text('Belum ada iklan yang dicek. Yuk mulai cek iklan pertamamu!',
                      style: t.bodyMedium?.copyWith(color: AppColors.ink500)),
                )
              else if (context.windowSize.isCompact)
                for (final r in recent) ...[
                  HistoryCard(result: r, onTap: () => context.push(AppRoutes.result(r.id))),
                  const SizedBox(height: 12),
                ]
              else
                // Layar lebar: dua kartu berdampingan.
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    for (final (i, r) in recent.indexed) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(child: HistoryCard(result: r, onTap: () => context.push(AppRoutes.result(r.id)))),
                    ],
                  ]),
                ),
              const SizedBox(height: 12),
              SectionHeader(
                title: 'Sorotan Edukasi',
                actionLabel: 'Semua',
                onAction: () => context.go(AppRoutes.education),
              ),
              const SizedBox(height: 8),
              _HighlightCarousel(articles: content.articles),
              const SizedBox(height: 12),
              _TipCard(tip: content.tipOfTheDay(DateTime.now())),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ClipRRect(
      borderRadius: AppRadius.xlAll,
      child: Container(
        color: AppColors.primary600,
        child: Stack(children: [
          Positioned(right: -40, top: -50, child: _circle(180, 0.55)),
          Positioned(right: -30, bottom: -60, child: _circle(140, 0.35)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('CEK SEBELUM CHECKOUT', style: t.labelSmall?.copyWith(color: AppColors.accent100)),
              const SizedBox(height: 8),
              SizedBox(
                width: 250,
                child:
                    Text('Ragu dengan klaim iklan skincare?', style: t.titleLarge?.copyWith(color: AppColors.surface)),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 240,
                child: Text('Tempel deskripsi produk dan lihat skor overclaim-nya.',
                    style: t.bodyMedium?.copyWith(color: AppColors.surface.withValues(alpha: 0.85))),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                key: const Key('home-start-check'),
                onPressed: () => context.push(AppRoutes.check),
                style: OutlinedButton.styleFrom(side: BorderSide.none),
                icon: const Icon(Icons.document_scanner_outlined, size: 20),
                label: const Text('Mulai Cek'),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _circle(double s, double o) => Container(
        width: s,
        height: s,
        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary500.withValues(alpha: o)),
      );
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.value, required this.label, required this.color});

  final IconData icon;
  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text('$value', style: t.titleLarge?.copyWith(color: color)),
          Text(label, style: t.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});
  final String tip;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      color: AppColors.accent100,
      borderColor: null,
      onTap: () => context.go(AppRoutes.education),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const IconTile(icon: Icons.menu_book_outlined, color: AppColors.accent600, background: AppColors.surface),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Tahukah kamu?', style: t.titleSmall?.copyWith(color: AppColors.accent600)),
            const SizedBox(height: 4),
            Text(tip, style: t.bodyMedium),
          ]),
        ),
      ]),
    );
  }
}

/// Carousel artikel edukasi (Material 3 [CarouselView]).
class _HighlightCarousel extends StatelessWidget {
  const _HighlightCarousel({required this.articles});
  final List<Article> articles;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SizedBox(
      height: 190,
      child: CarouselView(
        itemExtent: context.windowSize.isCompact ? 290 : 360,
        shrinkExtent: 200,
        itemSnapping: true,
        padding: const EdgeInsets.only(right: 12),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        onTap: (i) => context.push(AppRoutes.article(articles[i].id)),
        children: [
          for (final a in articles)
            Stack(fit: StackFit.expand, children: [
              ArticleCover(article: a),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC14211F)],
                    stops: [0.35, 1],
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a.category.toUpperCase(), style: t.labelSmall?.copyWith(color: AppColors.accent100)),
                  const SizedBox(height: 4),
                  Text(a.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: t.titleSmall?.copyWith(color: AppColors.surface)),
                ]),
              ),
            ]),
        ],
      ),
    );
  }
}
