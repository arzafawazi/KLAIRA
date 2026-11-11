@Tags(['golden'])
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:klaira/app.dart';
import 'package:klaira/core/router/app_router.dart';
import 'package:klaira/data/models/analysis_result.dart';
import 'package:klaira/data/models/enums.dart';
import 'package:klaira/features/splash/splash_screen.dart';

import '../helpers/test_fonts.dart';
import '../widget/app_flow_test.dart' show testDeps;

/// Tangkapan layar setiap layar (390 × 844 pt, seperti frame Figma).
/// Hasilnya tersimpan di `test/golden/goldens/` dan dipakai di README.
void main() {
  setUpAll(loadAppFonts);

  Future<GoRouter> boot(WidgetTester tester,
      {bool onboarding = true,
      double height = 844,
      double width = 390,
      Duration latency = const Duration(milliseconds: 100)}) async {
    tester.view.physicalSize = Size(width * 3, height * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final deps = await tester.runAsync(() => testDeps(onboardingDone: onboarding, analysisLatency: latency));
    await tester.pumpWidget(KlairaApp(deps: deps!));
    await tester.pump(SplashScreen.duration);
    await tester.pumpAndSettle();
    return GoRouter.of(tester.element(find.byType(Scaffold).first));
  }

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    await expectLater(find.byType(KlairaApp), matchesGoldenFile('goldens/$name.png'));
  }

  testWidgets('01 splash', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final deps = await tester.runAsync(() => testDeps());
    await tester.pumpWidget(KlairaApp(deps: deps!));
    await tester.pump(const Duration(milliseconds: 800));
    await expectLater(find.byType(KlairaApp), matchesGoldenFile('goldens/01_splash.png'));
    await tester.pump(SplashScreen.duration);
    await tester.pumpAndSettle();
  });

  testWidgets('02–04 onboarding', (tester) async {
    await boot(tester, onboarding: false);
    await shot(tester, '02_onboarding_1');
    await tester.tap(find.text('Lanjut'));
    await shot(tester, '03_onboarding_2');
    await tester.tap(find.text('Lanjut'));
    await shot(tester, '04_onboarding_3');
  });

  testWidgets('05 beranda', (tester) async {
    await boot(tester, height: 1040);
    await shot(tester, '05_beranda');
  });

  testWidgets('06 cek teks', (tester) async {
    final r = await boot(tester);
    unawaited(r.push(AppRoutes.check));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gunakan contoh'));
    await shot(tester, '06_cek_teks');
  });

  testWidgets('07 cek link', (tester) async {
    final r = await boot(tester);
    unawaited(r.push(AppRoutes.checkLink));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gunakan contoh link'));
    await tester.pump();
    await tester.tap(find.text('Ambil Deskripsi'));
    await tester.pump(const Duration(milliseconds: 100));
    await shot(tester, '07_cek_link');
  });

  testWidgets('08 menganalisis', (tester) async {
    final r = await boot(tester, latency: const Duration(seconds: 3));
    unawaited(r.push(AppRoutes.analyzing,
        extra: const AnalysisRequest(
            text: 'Serum ajaib 100% permanen menyembuhkan jerawat dalam 3 hari!', source: AdSource.shopee)));
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 600));
    await expectLater(find.byType(KlairaApp), matchesGoldenFile('goldens/08_menganalisis.png'));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('09 hasil analisis (panjang penuh)', (tester) async {
    final r = await boot(tester, height: 2600);
    unawaited(r.push(AppRoutes.result('seed-0')));
    await shot(tester, '09_hasil_analisis');
  });

  testWidgets('10 detail klaim', (tester) async {
    final r = await boot(tester, height: 1400);
    unawaited(r.push(AppRoutes.claim('seed-0', 'medical_claim')));
    await shot(tester, '10_detail_klaim');
  });

  testWidgets('11 riwayat', (tester) async {
    final r = await boot(tester, height: 1000);
    r.go(AppRoutes.history);
    await shot(tester, '11_riwayat');
  });

  testWidgets('12 edukasi', (tester) async {
    final r = await boot(tester, height: 1180);
    r.go(AppRoutes.education);
    await shot(tester, '12_edukasi');
  });

  testWidgets('13 detail artikel', (tester) async {
    final r = await boot(tester, height: 1320);
    unawaited(r.push(AppRoutes.article('enam-jenis-klaim')));
    await shot(tester, '13_detail_artikel');
  });

  testWidgets('14 profil', (tester) async {
    final r = await boot(tester, height: 1000);
    r.go(AppRoutes.profile);
    await shot(tester, '14_profil');
  });

  // ---------------------------------------------------------------- adaptif
  testWidgets('15 tablet beranda (NavigationRail)', (tester) async {
    await boot(tester, width: 1280, height: 800);
    await shot(tester, '15_tablet_beranda');
  });

  testWidgets('16 tablet hasil analisis (dua kolom)', (tester) async {
    final r = await boot(tester, width: 1280, height: 1300);
    unawaited(r.push(AppRoutes.result('seed-0')));
    await shot(tester, '16_tablet_hasil_dua_kolom');
  });

  testWidgets('17 tablet edukasi (grid)', (tester) async {
    final r = await boot(tester, width: 1280, height: 900);
    r.go(AppRoutes.education);
    await shot(tester, '17_tablet_edukasi_grid');
  });

  testWidgets('18 HP lanskap onboarding', (tester) async {
    await boot(tester, width: 844, height: 390, onboarding: false);
    await shot(tester, '18_lanskap_onboarding');
  });

  testWidgets('19 HP lanskap beranda', (tester) async {
    await boot(tester, width: 844, height: 390);
    await shot(tester, '19_lanskap_beranda');
  });
}
