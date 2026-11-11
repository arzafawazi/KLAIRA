import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/analysis_result.dart';
import 'common.dart';

/// Kartu riwayat analisis (Figma: `History Item`).
class HistoryCard extends StatelessWidget {
  const HistoryCard({super.key, required this.result, this.onTap});

  final AnalysisResult result;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = result.category;
    return Semantics(
      button: true,
      label: '${result.product}, skor ${result.score}, ${c.label}',
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
        child: Row(children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.background, borderRadius: AppRadius.mdAll),
            child: Text('${result.score}', style: t.titleLarge?.copyWith(color: c.color)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(
                  child: Text(result.product, style: t.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                if (result.saved) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.bookmark_rounded, size: 14, color: AppColors.primary600),
                ],
              ]),
              const SizedBox(height: 2),
              Text('${result.source.label} · ${Fmt.relative(result.analyzedAt)}', style: t.bodySmall),
              const SizedBox(height: 6),
              StatusBadge(category: c),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.ink300),
        ]),
      ),
    );
  }
}
