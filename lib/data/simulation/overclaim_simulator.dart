import 'dart:math' as math;

import '../models/analysis_result.dart';
import '../models/enums.dart';
import 'overclaim_lexicon.dart';

/// Simulator deteksi overclaim untuk prototipe.
///
/// Meniru alur model pada proposal (Gambar 3.2):
/// 1. **Ekstraksi fitur** — menghitung kemunculan frasa per kategori lalu
///    mengubahnya menjadi derajat keanggotaan 0–1 (μ = 1 − e^(−k·n)).
/// 2. **Fuzzifikasi** — memetakan μ ke himpunan RENDAH / SEDANG / TINGGI.
/// 3. **Inferensi** — mengevaluasi aturan JIKA–MAKA (operator DAN = minimum).
/// 4. **Defuzzifikasi** — rata-rata terbobot Sugeno orde nol → skor 0–100.
///
/// Simulator ini *deterministik* sehingga mudah diuji, dan menghasilkan
/// [AnalysisResult] dengan struktur yang sama persis seperti keluaran model.
class OverclaimSimulator {
  const OverclaimSimulator();

  AnalysisResult analyze(
    AnalysisRequest request, {
    required String id,
    DateTime? now,
  }) {
    final text = request.text.trim();
    final lower = text.toLowerCase();

    // ---- 1. Ekstraksi fitur & frasa ---------------------------------------
    final phrases = <FlaggedPhrase>[];
    final features = <TextualFeature>[];
    for (final f in OverclaimLexicon.features) {
      final found = <_Match>[];
      for (final p in f.patterns) {
        for (final m in RegExp(p, caseSensitive: false).allMatches(lower)) {
          if (m.end > m.start) found.add(_Match(m.start, m.end));
        }
      }
      final unique = _removeOverlaps(found);
      final membership = _saturate(unique.length, f.steepness);
      features.add(TextualFeature(
        id: f.id,
        label: f.label,
        membership: membership,
        level: ClaimLevel.fromMembership(membership),
        matches: unique.map((m) => text.substring(m.start, m.end)).toSet().toList(),
      ));
      for (final m in unique) {
        phrases.add(FlaggedPhrase(
          text: text.substring(m.start, m.end),
          start: m.start,
          end: m.end,
          level: f.highSeverity ? ClaimLevel.high : ClaimLevel.medium,
          featureId: f.id,
        ));
      }
    }

    // Gaya bahasa emosional: kata HURUF KAPITAL (≥4 huruf) & tanda seru.
    final caps = RegExp(r'\b[A-Z]{4,}\b').allMatches(text).toList();
    final exclaims = '!'.allMatches(text).length;
    final emotional = math.min(1.0, caps.length * 0.12 + exclaims * 0.06);
    features.add(TextualFeature(
      id: ClaimFeatureId.emotional,
      label: OverclaimLexicon.emotionalLabel,
      membership: _round2(emotional),
      level: ClaimLevel.fromMembership(emotional),
      matches: caps.map((m) => m.group(0)!).toSet().toList(),
    ));
    for (final m in caps) {
      phrases.add(FlaggedPhrase(
        text: m.group(0)!,
        start: m.start,
        end: m.end,
        level: ClaimLevel.medium,
        featureId: ClaimFeatureId.emotional,
      ));
    }

    // ---- 2–4. Fuzzifikasi, inferensi, defuzzifikasi ------------------------
    double mu(String id) => features.firstWhere((f) => f.id == id).membership;
    final a = mu(ClaimFeatureId.absolute);
    final med = mu(ClaimFeatureId.medical);
    final t = mu(ClaimFeatureId.time);
    final au = mu(ClaimFeatureId.authority);
    final s = mu(ClaimFeatureId.superlative);
    final e = mu(ClaimFeatureId.emotional);

    final fired = <_FiredRule>[
      _FiredRule('kata absolut TINGGI DAN klaim medis TINGGI', ClaimLevel.high, 95, math.min(_high(a), _high(med))),
      _FiredRule('klaim medis TINGGI', ClaimLevel.high, 90, _high(med)),
      _FiredRule('kata absolut TINGGI', ClaimLevel.high, 85, _high(a)),
      _FiredRule('klaim waktu ${_term(t)} DAN klaim otoritas ${_term(au)}', ClaimLevel.medium, 68,
          math.min(_atLeastMedium(t), _atLeastMedium(au))),
      _FiredRule('klaim waktu TINGGI', ClaimLevel.medium, 62, _high(t)),
      _FiredRule('klaim otoritas TINGGI', ClaimLevel.medium, 60, _high(au)),
      _FiredRule('superlatif ${_term(s)}', ClaimLevel.medium, 55, _atLeastMedium(s)),
      _FiredRule('kata absolut SEDANG', ClaimLevel.medium, 50, _medium(a)),
      _FiredRule('bahasa emosional TINGGI', ClaimLevel.medium, 45, _high(e)),
      _FiredRule('kata absolut RENDAH DAN klaim medis RENDAH DAN klaim waktu RENDAH', ClaimLevel.low, 8,
          [_low(a), _low(med), _low(t)].reduce(math.min)),
    ];

    final active = fired.where((r) => r.strength > 0.01).toList();
    final sumW = active.fold<double>(0, (p, r) => p + r.strength);
    final score =
        sumW == 0 ? 5 : (active.fold<double>(0, (p, r) => p + r.strength * r.output) / sumW).round().clamp(0, 100);

    active.sort((x, y) => y.strength.compareTo(x.strength));
    final rules = <FuzzyRule>[];
    for (var i = 0; i < math.min(3, active.length); i++) {
      final r = active[i];
      rules.add(FuzzyRule(
        id: 'R${i + 1}',
        text: 'JIKA ${r.condition} MAKA overclaim ${r.outputLevel.fuzzyTerm}',
        strength: _round2(r.strength),
        outputLevel: r.outputLevel,
      ));
    }

    final maxStrength = active.isEmpty ? 0.0 : active.first.strength;
    final confidence = _round2((0.7 + 0.25 * maxStrength).clamp(0.0, 0.96));

    phrases.sort((x, y) => x.start.compareTo(y.start));
    return AnalysisResult(
      id: id,
      product: _productName(request, text),
      source: request.source,
      analyzedAt: now ?? DateTime.now(),
      inputText: text,
      score: score,
      confidence: confidence,
      flaggedPhrases: _dedupePhrases(phrases),
      features: features,
      rules: rules,
    );
  }

  // ---------------------------------------------------------------- helpers
  static double _saturate(int n, double k) => _round2(1 - math.exp(-k * n));
  static double _round2(double v) => (v * 100).roundToDouble() / 100;

  // Fungsi keanggotaan himpunan fuzzy pada semesta 0–1.
  static double _low(double x) => x <= 0.2 ? 1 : (x >= 0.45 ? 0 : (0.45 - x) / 0.25);
  static double _medium(double x) => x <= 0.25 || x >= 0.75 ? 0 : (x <= 0.5 ? (x - 0.25) / 0.25 : (0.75 - x) / 0.25);
  static double _high(double x) => x <= 0.55 ? 0 : (x >= 0.8 ? 1 : (x - 0.55) / 0.25);
  static double _atLeastMedium(double x) => math.max(_medium(x), _high(x));
  static String _term(double x) => _high(x) >= _medium(x) ? 'TINGGI' : 'SEDANG';

  static List<_Match> _removeOverlaps(List<_Match> matches) {
    final sorted = [...matches]
      ..sort((a, b) => a.start != b.start ? a.start.compareTo(b.start) : b.length.compareTo(a.length));
    final out = <_Match>[];
    for (final m in sorted) {
      if (out.isEmpty || m.start >= out.last.end) out.add(m);
    }
    return out;
  }

  static List<FlaggedPhrase> _dedupePhrases(List<FlaggedPhrase> phrases) {
    final out = <FlaggedPhrase>[];
    for (final p in phrases) {
      if (out.isNotEmpty && p.start < out.last.end) {
        // Utamakan frasa dengan tingkat lebih tinggi / lebih panjang.
        final last = out.last;
        final better =
            p.level.index > last.level.index || (p.level == last.level && (p.end - p.start) > (last.end - last.start));
        if (better) out[out.length - 1] = p;
        continue;
      }
      out.add(p);
    }
    return out;
  }

  static String _productName(AnalysisRequest r, String text) {
    final name = r.productName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final words = text.split(RegExp(r'\s+')).take(4).join(' ');
    final clean = words.replaceAll(RegExp(r'[^\w\s%-]'), '').trim();
    return clean.isEmpty ? 'Iklan tanpa nama' : _titleCase(clean);
  }

  static String _titleCase(String s) =>
      s.split(' ').map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' ');
}

class _Match {
  const _Match(this.start, this.end);
  final int start;
  final int end;
  int get length => end - start;
}

class _FiredRule {
  const _FiredRule(this.condition, this.outputLevel, this.output, this.strength);
  final String condition;
  final ClaimLevel outputLevel;

  /// Nilai keluaran konsekuen (Sugeno orde nol), skala 0–100.
  final double output;
  final double strength;
}
