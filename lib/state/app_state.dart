import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/analysis_result.dart';
import '../data/models/content.dart';
import '../data/models/enums.dart';
import '../data/simulation/overclaim_simulator.dart';

/// State global aplikasi: riwayat analisis, status onboarding, preferensi.
///
/// Disimpan di perangkat dengan [SharedPreferences] sehingga riwayat tetap
/// ada setelah aplikasi ditutup. Tidak ada data yang dikirim ke server.
class AppState extends ChangeNotifier {
  AppState(this._prefs);

  final SharedPreferences _prefs;

  static const _kOnboarding = 'onboarding_done';
  static const _kHistory = 'history_v1';
  static const _kName = 'user_name';
  static const _kEduNotif = 'edu_notification';
  static const defaultName = 'Nadia'; // proto-persona (Tabel 3.1 proposal)

  bool _onboardingDone = false;
  String _userName = defaultName;
  bool _eduNotification = true;
  List<AnalysisResult> _history = [];

  bool get onboardingDone => _onboardingDone;
  String get userName => _userName;
  bool get eduNotification => _eduNotification;

  /// Riwayat terbaru di urutan teratas.
  List<AnalysisResult> get history => List.unmodifiable(_history);
  List<AnalysisResult> recent([int n = 2]) => _history.take(n).toList();

  int get totalChecked => _history.length;
  int get savedCount => _history.where((r) => r.saved).length;
  int countOf(OverclaimCategory c) => _history.where((r) => r.category == c).length;

  String get initials {
    final parts = _userName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'K';
    return (parts.first[0] + (parts.length > 1 ? parts[1][0] : '')).toUpperCase();
  }

  AnalysisResult? byId(String id) {
    for (final r in _history) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Memuat data tersimpan. Jika belum ada riwayat, isi dengan contoh
  /// dari [seedAds] agar layar Beranda & Riwayat tidak kosong saat demo.
  Future<void> init({List<SampleAd> seedAds = const [], DateTime? now}) async {
    _onboardingDone = _prefs.getBool(_kOnboarding) ?? false;
    _userName = _prefs.getString(_kName) ?? defaultName;
    _eduNotification = _prefs.getBool(_kEduNotif) ?? true;

    final raw = _prefs.getString(_kHistory);
    if (raw != null) {
      try {
        _history =
            (jsonDecode(raw) as List<dynamic>).map((e) => AnalysisResult.fromJson(e as Map<String, dynamic>)).toList();
      } on Object catch (e) {
        debugPrint('Riwayat rusak, dibuat ulang: $e');
        _history = [];
      }
    } else {
      _history = _seed(seedAds, now ?? DateTime.now());
      await _persist();
    }
  }

  List<AnalysisResult> _seed(List<SampleAd> ads, DateTime now) {
    const sim = OverclaimSimulator();
    final out = <AnalysisResult>[];
    for (var i = 0; i < ads.length; i++) {
      final ad = ads[i];
      final at = DateTime(now.year, now.month, now.day, 10 - i, 24 - i * 7).subtract(Duration(days: ad.daysAgo));
      out.add(sim.analyze(
        AnalysisRequest(text: ad.text, source: AdSource.fromId(ad.source), productName: ad.product),
        id: 'seed-$i',
        now: at,
      ));
    }
    out.sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
    return out;
  }

  Future<void> addResult(AnalysisResult result) async {
    _history = [result, ..._history.where((r) => r.id != result.id)];
    notifyListeners();
    await _persist();
  }

  Future<void> toggleSaved(String id) async {
    _history = [for (final r in _history) r.id == id ? r.copyWith(saved: !r.saved) : r];
    notifyListeners();
    await _persist();
  }

  /// Menghapus satu riwayat. Kembalikan item & posisinya untuk fitur "Urungkan".
  Future<(AnalysisResult, int)?> remove(String id) async {
    final index = _history.indexWhere((r) => r.id == id);
    if (index < 0) return null;
    final removed = _history[index];
    _history = [..._history]..removeAt(index);
    notifyListeners();
    await _persist();
    return (removed, index);
  }

  Future<void> restore(AnalysisResult result, int index) async {
    _history = [..._history]..insert(index.clamp(0, _history.length), result);
    notifyListeners();
    await _persist();
  }

  Future<void> clearHistory() async {
    _history = [];
    notifyListeners();
    await _persist();
  }

  Future<void> completeOnboarding() async {
    _onboardingDone = true;
    notifyListeners();
    await _prefs.setBool(_kOnboarding, true);
  }

  Future<void> resetOnboarding() async {
    _onboardingDone = false;
    notifyListeners();
    await _prefs.setBool(_kOnboarding, false);
  }

  Future<void> setUserName(String name) async {
    final v = name.trim();
    if (v.isEmpty) return;
    _userName = v;
    notifyListeners();
    await _prefs.setString(_kName, v);
  }

  Future<void> setEduNotification(bool value) async {
    _eduNotification = value;
    notifyListeners();
    await _prefs.setBool(_kEduNotif, value);
  }

  Future<void> _persist() => _prefs.setString(_kHistory, jsonEncode(_history.map((r) => r.toJson()).toList()));
}
