/// Kode fitur tekstual. Sama dengan `id` pada kontrak data JSON.
abstract final class ClaimFeatureId {
  static const absolute = 'absolute_words';
  static const medical = 'medical_claim';
  static const time = 'unrealistic_time';
  static const authority = 'authority_claim';
  static const superlative = 'superlative';
  static const emotional = 'emotional_style';

  static const all = [absolute, medical, time, authority, superlative, emotional];
}

/// Definisi satu fitur leksikal untuk simulator.
class LexiconFeature {
  const LexiconFeature({
    required this.id,
    required this.label,
    required this.ruleTerm,
    required this.patterns,
    required this.steepness,
    required this.highSeverity,
  });

  final String id;

  /// Label tampilan, mis. "Kata absolut & hiperbolik".
  final String label;

  /// Istilah pendek untuk teks aturan fuzzy, mis. "kata absolut".
  final String ruleTerm;

  /// Pola regex (huruf kecil). Dicocokkan secara case-insensitive.
  final List<String> patterns;

  /// Kecuraman fungsi jenuh μ = 1 − e^(−k·n). Makin besar, makin cepat tinggi.
  final double steepness;

  /// Frasa dari fitur ini ditandai merah (tinggi) atau kuning (sedang).
  final bool highSeverity;
}

/// Leksikon klaim berlebihan Bahasa Indonesia.
///
/// Disusun dari kategori pada Tabel 2.1 proposal (regulasi BPOM dan contoh
/// pelanggaran penelitian terdahulu). **Hanya untuk simulasi prototipe**;
/// pada versi final, fitur dihitung oleh pipeline NLP + model neurofuzzy.
abstract final class OverclaimLexicon {
  static const features = <LexiconFeature>[
    LexiconFeature(
      id: ClaimFeatureId.absolute,
      label: 'Kata absolut & hiperbolik',
      ruleTerm: 'kata absolut',
      steepness: 0.6,
      highSeverity: true,
      patterns: [
        r'100\s?%(\s+[a-z]+)?',
        r'permanen',
        r'dijamin(\s+[a-z]+)?(\s+tanpa efek samping)?',
        r'garansi hasil',
        r'pasti (berhasil|putih|cerah|hilang|glowing)',
        r'ajaib',
        r'tuntas',
        r'selamanya',
        r'tanpa efek samping',
        r'sempurna',
        r'hilang total',
      ],
    ),
    LexiconFeature(
      id: ClaimFeatureId.medical,
      label: 'Klaim medis / terapeutik',
      ruleTerm: 'klaim medis',
      steepness: 1.9,
      highSeverity: true,
      patterns: [
        r'menyembuhkan(\s+[a-z]+){0,2}',
        r'mengobati(\s+[a-z]+){0,2}',
        r'penyembuhan',
        r'terapi',
        r'eksim',
        r'dermatitis',
        r'infeksi',
        r'penyakit kulit',
        r'mencegah kanker',
      ],
    ),
    LexiconFeature(
      id: ClaimFeatureId.time,
      label: 'Klaim waktu tidak realistis',
      ruleTerm: 'klaim waktu',
      steepness: 0.5,
      highSeverity: false,
      patterns: [
        r'(hanya\s+)?dalam\s+\d+\s+(hari|jam|menit|minggu)',
        r'hanya\s+\d+\s+(hari|jam|menit)',
        r'(secara\s+)?instan',
        r'seketika',
        r'dalam waktu singkat',
        r'sekali (pakai|oles)',
        r'langsung (putih|cerah|glowing|hilang|mulus)',
        r'dalam semalam',
      ],
    ),
    LexiconFeature(
      id: ClaimFeatureId.authority,
      label: 'Klaim otoritas tanpa sumber',
      ruleTerm: 'klaim otoritas',
      steepness: 0.45,
      highSeverity: false,
      patterns: [
        r'(sudah\s+)?terbukti(\s+secara)?\s+klinis',
        r'uji klinis',
        r'(di)?rekomendasi(kan)? dokter( kulit)?',
        r'dermatolog[a-z]*',
        r'terbukti (ilmiah|secara ilmiah)',
        r'disetujui (dokter|ahli)',
      ],
    ),
    LexiconFeature(
      id: ClaimFeatureId.superlative,
      label: 'Superlatif tanpa bukti',
      ruleTerm: 'superlatif',
      steepness: 0.55,
      highSeverity: false,
      patterns: [
        r'(produk\s+)?terbaik(\s+(nomor|no\.?)\s*(1|satu))?',
        r'nomor\s*(1|satu)',
        r'paling (ampuh|bagus|efektif|cepat|aman)',
        r'terampuh',
        r'tercepat',
        r'satu-satunya',
        r'number one',
      ],
    ),
  ];

  /// Fitur gaya bahasa (huruf kapital & seruan) dihitung terpisah.
  static const emotionalLabel = 'Huruf kapital & seruan';
  static const emotionalRuleTerm = 'bahasa emosional';
}
