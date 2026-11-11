import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/analysis_result.dart';
import '../../data/repositories/analysis_repository.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/klaira_logo.dart';
import '../../state/app_state.dart';
import '../../core/utils/responsive.dart';

/// 08 Menganalisis — menampilkan tahapan pipeline selama model bekerja.
class AnalyzingScreen extends StatefulWidget {
  const AnalyzingScreen({super.key, required this.request});

  final AnalysisRequest request;

  static const steps = [
    ('Pra-pemrosesan teks', 'Case folding, tokenisasi, stopword'),
    ('Ekstraksi fitur tekstual', 'Kata absolut, klaim medis, superlatif'),
    ('Inferensi neurofuzzy', 'Fuzzifikasi → aturan → defuzzifikasi'),
    ('Menyusun penjelasan', 'Aturan yang paling berpengaruh'),
  ];

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
    ..repeat();
  Timer? _stepTimer;
  int _step = 0;
  bool _cancelled = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _stepTimer = Timer.periodic(const Duration(milliseconds: 550), (t) {
      if (_step < AnalyzingScreen.steps.length - 1) setState(() => _step++);
    });
    _run();
  }

  Future<void> _run() async {
    try {
      final result = await context.read<AnalysisRepository>().analyze(widget.request);
      if (!mounted || _cancelled) return;
      setState(() => _step = AnalyzingScreen.steps.length);
      await context.read<AppState>().addResult(result);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (mounted && !_cancelled) context.pushReplacement(AppRoutes.result(result.id));
    } on AnalysisException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on Object {
      if (mounted) setState(() => _error = 'Terjadi kesalahan. Coba lagi beberapa saat lagi.');
    }
  }

  void _cancel() {
    _cancelled = true;
    context.pop();
  }

  @override
  void dispose() {
    _spin.dispose();
    _stepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return PopScope(
      onPopInvokedWithResult: (didPop, _) => _cancelled = true,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleIconButton(icon: Icons.close_rounded, tooltip: 'Batalkan', onPressed: _cancel, size: 40),
            ),
          ],
        ),
        body: ResponsiveCenter(
            maxWidth: 560,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              children: [
                Center(
                  child: SizedBox.square(
                    dimension: 140,
                    child: Stack(alignment: Alignment.center, children: [
                      RotationTransition(
                        turns: _spin,
                        child: const SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: 0.7,
                            strokeWidth: 7,
                            strokeCap: StrokeCap.round,
                            backgroundColor: AppColors.primary100,
                          ),
                        ),
                      ),
                      const KlairaLogo(size: 72),
                    ]),
                  ),
                ),
                const SizedBox(height: 28),
                Text(_error == null ? 'Menganalisis klaim…' : 'Analisis gagal',
                    style: t.titleLarge, textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text(_error ?? 'Biasanya selesai dalam kurang dari 5 detik.',
                    style: t.bodyMedium?.copyWith(color: _error == null ? AppColors.ink500 : AppColors.danger),
                    textAlign: TextAlign.center),
                const SizedBox(height: 28),
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    for (var i = 0; i < AnalyzingScreen.steps.length; i++) ...[
                      _StepRow(
                        title: AnalyzingScreen.steps[i].$1,
                        subtitle: AnalyzingScreen.steps[i].$2,
                        state: i < _step ? _StepState.done : (i == _step ? _StepState.active : _StepState.todo),
                      ),
                      if (i < AnalyzingScreen.steps.length - 1) const SizedBox(height: 16),
                    ],
                  ]),
                ),
              ],
            )),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: _error == null
              ? TextButton(onPressed: _cancel, child: const Text('Batalkan'))
              : FilledButton(onPressed: () => context.pop(), child: const Text('Kembali & Perbaiki Teks')),
        ),
      ),
    );
  }
}

enum _StepState { done, active, todo }

class _StepRow extends StatelessWidget {
  const _StepRow({required this.title, required this.subtitle, required this.state});
  final String title;
  final String subtitle;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final (bg, child) = switch (state) {
      _StepState.done => (AppColors.safeBg, const Icon(Icons.check_rounded, size: 16, color: AppColors.safe)),
      _StepState.active => (
          AppColors.primary50,
          const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2.5)),
        ),
      _StepState.todo => (
          AppColors.ink100,
          Container(
              width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.ink300, shape: BoxShape.circle)),
        ),
    };
    return Row(children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: child,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: t.titleSmall?.copyWith(color: state == _StepState.todo ? AppColors.ink500 : AppColors.ink900)),
          Text(subtitle, style: t.bodySmall),
        ]),
      ),
    ]);
  }
}
