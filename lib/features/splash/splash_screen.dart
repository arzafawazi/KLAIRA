import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_info.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/klaira_logo.dart';
import '../../state/app_state.dart';

/// 01 Splash — tampil 1,5 detik lalu ke Onboarding (pertama kali) atau Beranda.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const duration = Duration(milliseconds: 1500);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(SplashScreen.duration, () {
      if (!mounted) return;
      final done = context.read<AppState>().onboardingDone;
      context.go(done ? AppRoutes.home : AppRoutes.onboarding);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.primary600,
        body: Stack(children: [
          Positioned(left: -120, top: -80, child: _circle(320, 0.35)),
          Positioned(right: -190, bottom: -60, child: _circle(360, 0.25)),
          SafeArea(
            child: Column(children: [
              Expanded(
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.85, end: 1),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutBack,
                    builder: (_, s, child) => Transform.scale(scale: s, child: child),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const KlairaLogo(size: 88, variant: LogoVariant.accent),
                      const SizedBox(height: 16),
                      Text(AppInfo.name, style: t.displaySmall?.copyWith(color: AppColors.surface, fontSize: 40)),
                      const SizedBox(height: 8),
                      Text(AppInfo.tagline,
                          style: t.bodyLarge?.copyWith(color: AppColors.surface.withValues(alpha: 0.8))),
                    ]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.eco_outlined, size: 16, color: AppColors.accent500),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(AppInfo.sdgFooter,
                        textAlign: TextAlign.center,
                        style: t.bodySmall?.copyWith(color: AppColors.surface.withValues(alpha: 0.75))),
                  ),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _circle(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary500.withValues(alpha: opacity),
        ),
      );
}
