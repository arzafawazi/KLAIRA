import 'package:flutter/foundation.dart';

import 'enums.dart';

/// Frasa pada teks iklan yang terindikasi overclaim.
///
/// [start] dan [end] adalah indeks karakter pada [AnalysisResult.inputText]
/// (end eksklusif), sehingga antarmuka bisa menandai frasa secara tepat.
@immutable
class FlaggedPhrase {
  const FlaggedPhrase({
    required this.text,
    required this.start,
    required this.end,
    required this.level,
    required this.featureId,
  });

  final String text;
  final int start;
  final int end;
  final ClaimLevel level;
  final String featureId;

  factory FlaggedPhrase.fromJson(Map<String, dynamic> json) => FlaggedPhrase(
        text: json['text'] as String,
        start: json['start'] as int,
        end: json['end'] as int,
        level: ClaimLevel.fromId(json['level'] as String),
        featureId: json['feature_id'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'text': text,
        'start': start,
        'end': end,
        'level': level.id,
        'feature_id': featureId,
      };
}

/// Fitur tekstual yang menjadi masukan model neurofuzzy.
@immutable
class TextualFeature {
  const TextualFeature({
    required this.id,
    required this.label,
    required this.membership,
    required this.level,
    this.matches = const [],
  });

  /// Kode fitur, mis. `absolute_words`, `medical_claim` (lihat `ClaimFeatureId`).
  final String id;
  final String label;

  /// Derajat keanggotaan pada rentang 0–1.
  final double membership;
  final ClaimLevel level;

  /// Kata/frasa pemicu yang ditemukan di teks.
  final List<String> matches;

  bool get isActive => membership >= 0.2;

  factory TextualFeature.fromJson(Map<String, dynamic> json) => TextualFeature(
        id: json['id'] as String,
        label: json['label'] as String,
        membership: (json['membership'] as num).toDouble(),
        level: ClaimLevel.fromId(json['level'] as String),
        matches: (json['matches'] as List<dynamic>? ?? const []).cast<String>(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'membership': membership,
        'level': level.id,
        'matches': matches,
      };
}

/// Aturan fuzzy "JIKA–MAKA" yang aktif beserta kekuatan penyulutannya.
@immutable
class FuzzyRule {
  const FuzzyRule({
    required this.id,
    required this.text,
    required this.strength,
    required this.outputLevel,
  });

  final String id;
  final String text;

  /// Firing strength (0–1).
  final double strength;
  final ClaimLevel outputLevel;

  factory FuzzyRule.fromJson(Map<String, dynamic> json) => FuzzyRule(
        id: json['id'] as String,
        text: json['text'] as String,
        strength: (json['strength'] as num).toDouble(),
        outputLevel: ClaimLevel.fromId(json['output_level'] as String? ?? 'high'),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'strength': strength,
        'output_level': outputLevel.id,
      };
}

/// Hasil analisis satu iklan. Struktur ini adalah **kontrak data** antara
/// aplikasi dan model neurofuzzy (lihat `docs/KONTRAK_DATA.md`).
@immutable
class AnalysisResult {
  const AnalysisResult({
    required this.id,
    required this.product,
    required this.source,
    required this.analyzedAt,
    required this.inputText,
    required this.score,
    required this.confidence,
    required this.flaggedPhrases,
    required this.features,
    required this.rules,
    this.disclaimer = defaultDisclaimer,
    this.saved = false,
  });

  static const defaultDisclaimer =
      'Hasil ini adalah indikasi awal berbasis analisis teks, bukan keputusan resmi BPOM maupun saran medis.';

  final String id;
  final String product;
  final AdSource source;
  final DateTime analyzedAt;
  final String inputText;

  /// Skor overclaim 0–100.
  final int score;

  /// Keyakinan model 0–1.
  final double confidence;
  final List<FlaggedPhrase> flaggedPhrases;
  final List<TextualFeature> features;
  final List<FuzzyRule> rules;
  final String disclaimer;

  /// Ditandai pengguna lewat tombol "Simpan".
  final bool saved;

  OverclaimCategory get category => OverclaimCategory.fromScore(score);
  int get activeFeatureCount => features.where((f) => f.isActive).length;

  List<TextualFeature> get featuresSorted => [...features]..sort((a, b) => b.membership.compareTo(a.membership));

  TextualFeature? featureById(String id) {
    for (final f in features) {
      if (f.id == id) return f;
    }
    return null;
  }

  AnalysisResult copyWith({bool? saved, String? product}) => AnalysisResult(
        id: id,
        product: product ?? this.product,
        source: source,
        analyzedAt: analyzedAt,
        inputText: inputText,
        score: score,
        confidence: confidence,
        flaggedPhrases: flaggedPhrases,
        features: features,
        rules: rules,
        disclaimer: disclaimer,
        saved: saved ?? this.saved,
      );

  factory AnalysisResult.fromJson(Map<String, dynamic> json) => AnalysisResult(
        id: json['id'] as String,
        product: json['product'] as String,
        source: AdSource.fromId(json['source'] as String),
        analyzedAt: DateTime.parse(json['analyzed_at'] as String),
        inputText: json['input_text'] as String,
        score: (json['score'] as num).round(),
        confidence: (json['confidence'] as num).toDouble(),
        flaggedPhrases: (json['flagged_phrases'] as List<dynamic>)
            .map((e) => FlaggedPhrase.fromJson(e as Map<String, dynamic>))
            .toList(),
        features:
            (json['features'] as List<dynamic>).map((e) => TextualFeature.fromJson(e as Map<String, dynamic>)).toList(),
        rules: (json['rules'] as List<dynamic>).map((e) => FuzzyRule.fromJson(e as Map<String, dynamic>)).toList(),
        disclaimer: json['disclaimer'] as String? ?? defaultDisclaimer,
        saved: json['saved'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'product': product,
        'source': source.id,
        'analyzed_at': analyzedAt.toIso8601String(),
        'input_text': inputText,
        'score': score,
        'category': category.id,
        'confidence': confidence,
        'flagged_phrases': flaggedPhrases.map((e) => e.toJson()).toList(),
        'features': features.map((e) => e.toJson()).toList(),
        'rules': rules.map((e) => e.toJson()).toList(),
        'disclaimer': disclaimer,
        'saved': saved,
      };
}

/// Permintaan analisis dari layar Cek Iklan.
@immutable
class AnalysisRequest {
  const AnalysisRequest({
    required this.text,
    required this.source,
    this.productName,
    this.url,
  });

  final String text;
  final AdSource source;
  final String? productName;
  final String? url;
}
