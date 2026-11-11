import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_info.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/klaira_logo.dart';
import '../../state/app_state.dart';
import 'onboarding_illustrations.dart';

/// 02–04 Onboarding — tiga slide pengenalan.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    (
      title: 'Iklan skincare sering melebih-lebihkan',
      body:
          'Klaim seperti “100% hilang permanen” atau “menyembuhkan jerawat” bisa menyesatkan dan membuatmu membeli produk yang tidak sesuai harapan.',
      kind: 0,
    ),
    (
      title: 'Cek klaim dalam hitungan detik',
      body:
          'Tempel deskripsi produk dari e-commerce. Klaira menganalisis fitur tekstual dengan model neurofuzzy, lalu menjelaskan alasan di balik skornya.',
      kind: 1,
    ),
    (
      title: 'Belanja lebih bijak, konsumsi lebih bertanggung jawab',
      body:
          'Informasi yang jujur membantumu terhindar dari pembelian sia-sia dan mendukung target SDG 12.8 tentang kesadaran gaya hidup berkelanjutan.',
      kind: 2,
    ),
  ];

  bool get _isLast => _page == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.read<AppState>().completeOnboarding();
    if (mounted) context.go(AppRoutes.home);
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 12, 8),
            child: Row(children: [
              const KlairaLogo(size: 28),
              const SizedBox(width: 8),
              Text(AppInfo.name, style: t.titleMedium?.copyWith(color: AppColors.primary700)),
              const Spacer(),
              AnimatedOpacity(
                opacity: _isLast ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: TextButton(
                  onPressed: _isLast ? null : _finish,
                  child: Text('Lewati', style: t.titleSmall?.copyWith(color: AppColors.ink500)),
                ),
              ),
            ]),
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) {
                final p = _pages[i];
                final illustration = Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  decoration: BoxDecoration(
                    color: p.kind == 2 ? AppColors.accent100 : AppColors.primary50,
                    borderRadius: AppRadius.xlAll,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: 300,
                      child: switch (p.kind) {
                        0 => const OverclaimAdIllustration(),
                        1 => const HowItWorksIllustration(),
                        _ => const Sdg12Illustration(),
                      },
                    ),
                  ),
                );
                final text = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.title, style: t.headlineSmall),
                  const SizedBox(height: 12),
                  Text(p.body, style: t.bodyLarge),
                ]);
                // Adaptif terhadap orientasi: lanskap → ilustrasi & teks berdampingan.
                return OrientationBuilder(
                  builder: (context, orientation) {
                    if (orientation == Orientation.landscape) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                        child: Row(children: [
                          Expanded(child: illustration),
                          const SizedBox(width: 32),
                          Expanded(child: SingleChildScrollView(child: text)),
                        ]),
                      );
                    }
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            SizedBox(height: 340, child: illustration),
                            const SizedBox(height: 32),
                            text,
                          ]),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: _isLast
                ? Column(children: [
                    _Dots(count: _pages.length, index: _page),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _next,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                        label: const Text('Mulai Sekarang'),
                      ),
                    ),
                  ])
                : Row(children: [
                    _Dots(count: _pages.length, index: _page),
                    const Spacer(),
                    FilledButton(onPressed: _next, child: const Text('Lanjut')),
                  ]),
          ),
        ]),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Halaman ${index + 1} dari $count',
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 6),
              width: i == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == index ? AppColors.primary600 : AppColors.ink200,
                borderRadius: AppRadius.fullAll,
              ),
            ),
        ]),
      );
}
