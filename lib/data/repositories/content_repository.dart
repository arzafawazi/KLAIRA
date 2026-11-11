import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/content.dart';

/// Memuat konten statis aplikasi dari `assets/data/*.json`.
///
/// Konten (artikel, kamus klaim, contoh iklan, tips) sengaja dipisah ke JSON
/// agar tim bisa mengubah teks tanpa menyentuh kode Dart.
class ContentRepository {
  ContentRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  List<Article> articles = const [];
  List<ClaimInsight> insights = const [];
  List<SampleAd> sampleAds = const [];
  List<String> tips = const [];

  Future<void> load() async {
    final results = await Future.wait([
      _bundle.loadString('assets/data/articles.json'),
      _bundle.loadString('assets/data/claim_insights.json'),
      _bundle.loadString('assets/data/sample_ads.json'),
      _bundle.loadString('assets/data/tips.json'),
    ]);
    articles =
        (jsonDecode(results[0]) as List<dynamic>).map((e) => Article.fromJson(e as Map<String, dynamic>)).toList();
    insights =
        (jsonDecode(results[1]) as List<dynamic>).map((e) => ClaimInsight.fromJson(e as Map<String, dynamic>)).toList();
    sampleAds =
        (jsonDecode(results[2]) as List<dynamic>).map((e) => SampleAd.fromJson(e as Map<String, dynamic>)).toList();
    tips = (jsonDecode(results[3]) as List<dynamic>).cast<String>();
  }

  Article? articleById(String id) {
    for (final a in articles) {
      if (a.id == id) return a;
    }
    return null;
  }

  ClaimInsight? insightFor(String featureId) {
    for (final i in insights) {
      if (i.featureId == featureId) return i;
    }
    return null;
  }

  Article? get featuredArticle {
    for (final a in articles) {
      if (a.featured) return a;
    }
    return articles.isEmpty ? null : articles.first;
  }

  List<String> get articleCategories {
    final set = <String>{};
    for (final a in articles) {
      if (!a.featured) set.add(a.category);
    }
    return set.toList();
  }

  /// Contoh iklan yang dipakai tombol "Gunakan contoh" di layar Cek Iklan.
  SampleAd get demoAd => sampleAds.first;

  /// Tips harian berganti sesuai tanggal.
  String tipOfTheDay(DateTime now) =>
      tips.isEmpty ? '' : tips[now.difference(DateTime(2026)).inDays.abs() % tips.length];
}
