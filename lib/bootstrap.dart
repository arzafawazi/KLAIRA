import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/repositories/analysis_repository.dart';
import 'data/repositories/content_repository.dart';
import 'state/app_state.dart';

/// Semua dependensi aplikasi, disiapkan sekali saat start.
class AppDependencies {
  const AppDependencies({
    required this.content,
    required this.analysis,
    required this.state,
  });

  final ContentRepository content;
  final AnalysisRepository analysis;
  final AppState state;
}

/// Menyiapkan format tanggal, konten, repository, dan state.
///
/// ➜ **Titik integrasi model:** ganti [DummyAnalysisRepository] di bawah
///   dengan implementasi yang memanggil API model neurofuzzy.
Future<AppDependencies> bootstrap({SharedPreferences? prefs}) async {
  await initializeDateFormatting('id_ID');
  Intl.defaultLocale = 'id_ID';
  final content = ContentRepository();
  await content.load();

  final analysis = DummyAnalysisRepository(content: content);

  final state = AppState(prefs ?? await SharedPreferences.getInstance());
  await state.init(seedAds: content.sampleAds);

  return AppDependencies(content: content, analysis: analysis, state: state);
}
