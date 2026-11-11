import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klaira/app.dart';
import 'package:klaira/bootstrap.dart';
import 'package:klaira/data/repositories/analysis_repository.dart';
import 'package:klaira/data/repositories/content_repository.dart';
import 'package:klaira/features/splash/splash_screen.dart';
import 'package:klaira/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers/test_fonts.dart';

/// Menyiapkan dependensi dengan jeda analisis yang singkat.
Future<AppDependencies> testDeps({
  bool onboardingDone = true,
  Duration analysisLatency = const Duration(milliseconds: 100),
}) async {
  SharedPreferences.setMockInitialValues({'onboarding_done': onboardingDone});
  await initializeDateFormatting('id_ID');
  final prefs = await SharedPreferences.getInstance();
  final content = ContentRepository();
  await content.load();
  final state = AppState(prefs);
  await state.init(seedAds: content.sampleAds);
  return AppDependencies(
    content: content,
    analysis: DummyAnalysisRepository(
      content: content,
      latency: analysisLatency,
      linkLatency: const Duration(milliseconds: 50),
    ),
    state: state,
  );
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('pengguna baru melihat onboarding setelah splash', (tester) async {
    final deps = await tester.runAsync(() => testDeps(onboardingDone: false));
    await tester.pumpWidget(KlairaApp(deps: deps!));
    expect(find.text('Klaira'), findsOneWidget);
    await tester.pump(SplashScreen.duration);
    await tester.pumpAndSettle();
    expect(find.text('Iklan skincare sering melebih-lebihkan'), findsOneWidget);
    expect(find.text('Lewati'), findsOneWidget);
  });

  testWidgets('alur utama: Beranda → Cek Iklan → Menganalisis → Hasil', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final deps = await tester.runAsync(() => testDeps());
    await tester.pumpWidget(KlairaApp(deps: deps!));
    await tester.pump(SplashScreen.duration);
    await tester.pumpAndSettle();

    // Beranda menampilkan riwayat contoh.
    expect(find.text('Riwayat Terakhir'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-start-check')));
    await tester.pumpAndSettle();
    expect(find.text('Apa yang ingin kamu cek?'), findsOneWidget);

    // Tombol analisis nonaktif sebelum teks diisi.
    final button = find.byKey(const Key('analyze-button'));
    expect(tester.widget<ButtonStyleButton>(button).onPressed, isNull);

    await tester.tap(find.text('Gunakan contoh'));
    await tester.pump();
    expect(tester.widget<ButtonStyleButton>(button).onPressed, isNotNull);

    final before = deps.state.totalChecked;
    await tester.tap(button);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    expect(find.text('Menganalisis klaim…'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Hasil Analisis'), findsOneWidget);
    expect(find.text('Overclaim'), findsWidgets);
    expect(deps.state.totalChecked, before + 1);
  });
}
