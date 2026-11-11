import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klaira/app.dart';
import 'package:klaira/core/utils/responsive.dart';
import 'package:klaira/features/splash/splash_screen.dart';

import '../helpers/test_fonts.dart';
import 'app_flow_test.dart' show testDeps;

Future<void> _pumpApp(WidgetTester tester, Size logicalSize, {bool onboarding = true}) async {
  tester.view.physicalSize = logicalSize * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  final deps = await tester.runAsync(() => testDeps(onboardingDone: onboarding));
  await tester.pumpWidget(KlairaApp(deps: deps!));
  await tester.pump(SplashScreen.duration);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  group('WindowSize', () {
    test('batas breakpoint Material 3', () {
      expect(WindowSize.fromWidth(390), WindowSize.compact);
      expect(WindowSize.fromWidth(599), WindowSize.compact);
      expect(WindowSize.fromWidth(600), WindowSize.medium);
      expect(WindowSize.fromWidth(839), WindowSize.medium);
      expect(WindowSize.fromWidth(840), WindowSize.expanded);
    });
  });

  testWidgets('HP potret memakai bottom navigation', (tester) async {
    await _pumpApp(tester, const Size(390, 844));
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byKey(const Key('nav-check')), findsOneWidget);
  });

  testWidgets('HP lanskap (≥ 840 dp) memakai NavigationRail diperluas', (tester) async {
    await _pumpApp(tester, const Size(844, 390));
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.extended, isTrue); // 844 dp ≥ 840 → expanded
  });

  testWidgets('tablet potret (medium) memakai NavigationRail tanpa label panjang', (tester) async {
    await _pumpApp(tester, const Size(744, 1133));
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.extended, isFalse);
  });

  testWidgets('onboarding lanskap menampilkan ilustrasi & teks berdampingan', (tester) async {
    await _pumpApp(tester, const Size(844, 390), onboarding: false);
    final illus = tester.getRect(find.text('Glowé Bright Serum'));
    final title = tester.getRect(find.text('Iklan skincare sering melebih-lebihkan'));
    expect(title.left, greaterThan(illus.right));
  });

  testWidgets('Kamus Klaim memakai GridView dengan kolom adaptif', (tester) async {
    await _pumpApp(tester, const Size(390, 844));
    await tester.tap(find.text('Edukasi'));
    await tester.pumpAndSettle();
    final grid = tester.widget<GridView>(find.byKey(const Key('glossary-grid')));
    final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 2);
  });
}
