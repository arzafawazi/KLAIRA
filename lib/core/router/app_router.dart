import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/analysis_result.dart';
import '../../features/check/analyzing_screen.dart';
import '../../features/check/check_screen.dart';
import '../../features/education/article_detail_screen.dart';
import '../../features/education/education_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/result/claim_detail_screen.dart';
import '../../features/result/result_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/splash/splash_screen.dart';

/// Daftar path. Gunakan helper ini alih-alih menulis string manual.
abstract final class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const history = '/history';
  static const education = '/education';
  static const profile = '/profile';
  static const check = '/check';
  static const checkLink = '/check?mode=link';
  static const analyzing = '/analyzing';
  static String result(String id) => '/result/$id';
  static String claim(String resultId, String featureId) => '/result/$resultId/claim/$featureId';
  static String article(String id) => '/article/$id';
}

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Peta navigasi aplikasi (lihat juga halaman 🔀 User Flow di Figma).
///
/// - 4 tab utama memakai [StatefulShellRoute] sehingga posisi scroll tiap tab
///   tetap terjaga saat berpindah tab.
/// - Layar turunan (Cek Iklan, Hasil, Artikel, dll.) dibuka di atas navigator
///   root sehingga bottom navigation tersembunyi.
GoRouter createRouter() => GoRouter(
      navigatorKey: _rootKey,
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
        GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),
        StatefulShellRoute.indexedStack(
          builder: (_, __, shell) => MainShell(shell: shell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: AppRoutes.history, builder: (_, __) => const HistoryScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: AppRoutes.education, builder: (_, __) => const EducationScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfileScreen()),
            ]),
          ],
        ),
        GoRoute(
          path: AppRoutes.check,
          parentNavigatorKey: _rootKey,
          builder: (_, state) => CheckScreen(
            initialMode: state.uri.queryParameters['mode'] == 'link' ? 1 : 0,
          ),
        ),
        GoRoute(
          path: AppRoutes.analyzing,
          parentNavigatorKey: _rootKey,
          redirect: (_, state) => state.extra is AnalysisRequest ? null : AppRoutes.check,
          pageBuilder: (_, state) => CustomTransitionPage(
            child: AnalyzingScreen(request: state.extra! as AnalysisRequest),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          ),
        ),
        GoRoute(
          path: '/result/:id',
          parentNavigatorKey: _rootKey,
          builder: (_, state) => ResultScreen(resultId: state.pathParameters['id']!),
          routes: [
            GoRoute(
              path: 'claim/:featureId',
              parentNavigatorKey: _rootKey,
              builder: (_, state) => ClaimDetailScreen(
                resultId: state.pathParameters['id']!,
                featureId: state.pathParameters['featureId']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/article/:id',
          parentNavigatorKey: _rootKey,
          builder: (_, state) => ArticleDetailScreen(articleId: state.pathParameters['id']!),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text('Halaman tidak ditemukan: ${state.uri}')),
      ),
    );
