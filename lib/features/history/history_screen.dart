import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/analysis_result.dart';
import '../../data/models/enums.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/history_card.dart';
import '../../state/app_state.dart';
import '../../core/utils/responsive.dart';

enum _Filter { all, saved, overclaim, waspada, aman }

/// 11 Riwayat — pencarian, filter, kelompok tanggal, geser untuk hapus.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _search = TextEditingController();
  _Filter _filter = _Filter.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _match(AnalysisResult r) {
    final q = _search.text.trim().toLowerCase();
    if (q.isNotEmpty && !r.product.toLowerCase().contains(q)) return false;
    return switch (_filter) {
      _Filter.all => true,
      _Filter.saved => r.saved,
      _Filter.overclaim => r.category == OverclaimCategory.overclaim,
      _Filter.waspada => r.category == OverclaimCategory.waspada,
      _Filter.aman => r.category == OverclaimCategory.aman,
    };
  }

  Future<void> _delete(AnalysisResult r) async {
    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    final removed = await state.remove(r.id);
    if (removed == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('“${r.product}” dihapus'),
        action: SnackBarAction(label: 'Urungkan', onPressed: () => state.restore(removed.$1, removed.$2)),
      ));
  }

  Future<void> _sortSheet() async {
    final t = Theme.of(context).textTheme;
    final state = context.read<AppState>();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Kelola riwayat', style: t.titleLarge),
          const SizedBox(height: 8),
          Text('Riwayat hanya tersimpan di perangkat ini.', style: t.bodyMedium),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
            title: Text('Hapus semua riwayat', style: t.titleSmall?.copyWith(color: AppColors.danger)),
            onTap: () => Navigator.pop(ctx, true),
          ),
        ]),
      ),
    );
    if (ok == true && mounted) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Hapus semua riwayat?'),
          content: const Text('Tindakan ini tidak dapat dibatalkan.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus', style: TextStyle(color: AppColors.danger)),
            ),
          ],
        ),
      );
      if (confirm == true) await state.clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final state = context.watch<AppState>();
    final items = state.history.where(_match).toList();

    final groups = <String, List<AnalysisResult>>{};
    for (final r in items) {
      groups.putIfAbsent(Fmt.group(r.analyzedAt), () => []).add(r);
    }

    return Scaffold(
      body: SafeArea(
        child: ResponsiveCenter(
            maxWidth: 840,
            child: CustomScrollView(slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: SliverList.list(children: [
                  Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Riwayat', style: t.headlineSmall),
                        Text('${state.totalChecked} iklan sudah kamu cek',
                            style: t.bodyMedium?.copyWith(color: AppColors.ink500)),
                      ]),
                    ),
                    CircleIconButton(icon: Icons.tune_rounded, tooltip: 'Kelola riwayat', onPressed: _sortSheet),
                  ]),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Cari nama produk…',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.ink500),
                      suffixIcon: _search.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Hapus pencarian',
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => setState(_search.clear),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ]),
              ),
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: [
                    for (final f in _Filter.values) ...[
                      ChoiceChip(
                        label: Text(switch (f) {
                          _Filter.all => 'Semua',
                          _Filter.saved => 'Tersimpan',
                          _Filter.overclaim => 'Overclaim',
                          _Filter.waspada => 'Waspada',
                          _Filter.aman => 'Aman',
                        }),
                        selected: _filter == f,
                        onSelected: (_) => setState(() => _filter = f),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ]),
                ),
              ),
              if (items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: state.history.isEmpty ? Icons.history_rounded : Icons.search_off_rounded,
                    title: state.history.isEmpty ? 'Belum ada riwayat' : 'Tidak ada hasil',
                    message: state.history.isEmpty
                        ? 'Hasil analisis iklan akan muncul di sini.'
                        : 'Coba ubah kata kunci atau filter.',
                    action: state.history.isEmpty
                        ? FilledButton.icon(
                            onPressed: () => context.push(AppRoutes.check),
                            icon: const Icon(Icons.document_scanner_outlined, size: 20),
                            label: const Text('Cek Iklan'),
                          )
                        : null,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList.list(children: [
                    for (final entry in groups.entries) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 8),
                        child: Text(entry.key.toUpperCase(), style: t.labelSmall),
                      ),
                      for (final r in entry.value)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: ValueKey(r.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _delete(r),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: AppColors.dangerBg,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                            ),
                            child: HistoryCard(result: r, onTap: () => context.push(AppRoutes.result(r.id))),
                          ),
                        ),
                    ],
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child:
                          Text('Geser kartu ke kiri untuk menghapus.', style: t.bodySmall, textAlign: TextAlign.center),
                    ),
                  ]),
                ),
            ])),
      ),
    );
  }
}
