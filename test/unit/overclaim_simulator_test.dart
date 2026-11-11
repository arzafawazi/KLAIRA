import 'package:flutter_test/flutter_test.dart';
import 'package:klaira/data/models/analysis_result.dart';
import 'package:klaira/data/models/enums.dart';
import 'package:klaira/data/simulation/overclaim_lexicon.dart';
import 'package:klaira/data/simulation/overclaim_simulator.dart';

void main() {
  const sim = OverclaimSimulator();
  AnalysisResult run(String text) =>
      sim.analyze(AnalysisRequest(text: text, source: AdSource.shopee), id: 't', now: DateTime(2026, 10, 14, 10, 24));

  const overclaimAd = 'Serum pemutih AJAIB! 100% menghilangkan flek hitam & bekas jerawat PERMANEN hanya dalam 7 hari. '
      'Dijamin aman tanpa efek samping dan sudah terbukti klinis. Menyembuhkan jerawat meradang serta '
      'mengecilkan pori-pori secara instan. Produk terbaik nomor 1 di Indonesia, direkomendasikan dokter kulit!';

  const safeAd = 'Pelembap ringan dengan ceramide untuk membantu menjaga kelembapan kulit. '
      'Gunakan pagi dan malam. Hasil dapat berbeda pada setiap jenis kulit.';

  group('OverclaimSimulator', () {
    test('iklan penuh klaim berlebihan dikategorikan Overclaim', () {
      final r = run(overclaimAd);
      expect(r.category, OverclaimCategory.overclaim);
      expect(r.score, greaterThanOrEqualTo(70));
      expect(r.featureById(ClaimFeatureId.medical)!.level, ClaimLevel.high);
      expect(r.featureById(ClaimFeatureId.absolute)!.level, ClaimLevel.high);
      expect(r.rules, isNotEmpty);
      expect(r.rules.first.text, startsWith('JIKA'));
    });

    test('iklan dengan klaim wajar dikategorikan Aman', () {
      final r = run(safeAd);
      expect(r.category, OverclaimCategory.aman);
      expect(r.flaggedPhrases, isEmpty);
    });

    test('iklan dengan klaim waktu & otoritas dikategorikan Waspada', () {
      final r = run('Gel jerawat dengan salicylic acid. Jerawat kempes dalam 3 hari! '
          'Produk terbaik untuk kulit berminyak dan direkomendasikan dokter kulit.');
      expect(r.category, OverclaimCategory.waspada);
    });

    test('indeks frasa ditandai sesuai teks asli dan tidak tumpang tindih', () {
      final r = run(overclaimAd);
      var lastEnd = -1;
      for (final p in r.flaggedPhrases) {
        expect(r.inputText.substring(p.start, p.end), p.text);
        expect(p.start, greaterThanOrEqualTo(lastEnd));
        lastEnd = p.end;
      }
    });

    test('mengembalikan enam fitur dengan derajat keanggotaan 0–1', () {
      final r = run(overclaimAd);
      expect(r.features.map((f) => f.id), containsAll(ClaimFeatureId.all));
      for (final f in r.features) {
        expect(f.membership, inInclusiveRange(0, 1));
      }
    });

    test('deterministik untuk input yang sama', () {
      expect(run(overclaimAd).score, run(overclaimAd).score);
    });
  });

  group('AnalysisResult JSON', () {
    test('toJson → fromJson menghasilkan data yang sama (kontrak data)', () {
      final r = run(overclaimAd);
      final copy = AnalysisResult.fromJson(r.toJson());
      expect(copy.score, r.score);
      expect(copy.category, r.category);
      expect(copy.flaggedPhrases.length, r.flaggedPhrases.length);
      expect(copy.features.length, r.features.length);
      expect(copy.rules.first.text, r.rules.first.text);
      expect(copy.analyzedAt, r.analyzedAt);
    });
  });

  group('OverclaimCategory.fromScore', () {
    test('batas kategori sesuai proposal', () {
      expect(OverclaimCategory.fromScore(0), OverclaimCategory.aman);
      expect(OverclaimCategory.fromScore(39), OverclaimCategory.aman);
      expect(OverclaimCategory.fromScore(40), OverclaimCategory.waspada);
      expect(OverclaimCategory.fromScore(69), OverclaimCategory.waspada);
      expect(OverclaimCategory.fromScore(70), OverclaimCategory.overclaim);
      expect(OverclaimCategory.fromScore(100), OverclaimCategory.overclaim);
    });
  });
}
