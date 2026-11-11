# Kontrak Data Hasil Analisis

Dokumen ini menjelaskan format JSON yang **harus dikembalikan model neurofuzzy** (atau API-nya) agar bisa langsung ditampilkan oleh aplikasi Klaira. Format ini sama dengan Lampiran 3 proposal dan diimplementasikan di `lib/data/models/analysis_result.dart` (`AnalysisResult.fromJson` / `toJson`).

## Contoh lengkap

```json
{
  "id": "1760412240000000",
  "product": "Glowé Bright Serum 7 Days",
  "source": "shopee",
  "analyzed_at": "2026-10-14T10:24:00+07:00",
  "input_text": "Serum pemutih AJAIB! 100% menghilangkan flek hitam ...",
  "score": 86,
  "category": "overclaim",
  "confidence": 0.91,
  "flagged_phrases": [
    { "text": "100% menghilangkan", "start": 21, "end": 39, "level": "high",   "feature_id": "absolute_words" },
    { "text": "hanya dalam 7 hari", "start": 76, "end": 94, "level": "medium", "feature_id": "unrealistic_time" }
  ],
  "features": [
    { "id": "absolute_words", "label": "Kata absolut & hiperbolik", "membership": 0.92, "level": "high",
      "matches": ["100% menghilangkan", "PERMANEN"] },
    { "id": "medical_claim",  "label": "Klaim medis / terapeutik",  "membership": 0.85, "level": "high",
      "matches": ["Menyembuhkan jerawat meradang"] }
  ],
  "rules": [
    { "id": "R1", "strength": 0.85, "output_level": "high",
      "text": "JIKA kata absolut TINGGI DAN klaim medis TINGGI MAKA overclaim TINGGI" }
  ],
  "disclaimer": "Hasil ini adalah indikasi awal berbasis analisis teks, bukan keputusan resmi BPOM maupun saran medis."
}
```

## Penjelasan field

| Field | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `id` | string | ✔ | ID unik hasil (mis. timestamp / UUID). |
| `product` | string | ✔ | Nama produk. |
| `source` | string | ✔ | `shopee` · `tokopedia` · `tiktok_shop` · `other`. |
| `analyzed_at` | string ISO-8601 | ✔ | Waktu analisis. |
| `input_text` | string | ✔ | Teks asli yang dianalisis (indeks frasa mengacu ke teks ini). |
| `score` | int 0–100 | ✔ | Skor overclaim hasil defuzzifikasi. |
| `category` | string | – | `aman` (0–39) · `waspada` (40–69) · `overclaim` (70–100). Aplikasi menghitung ulang dari `score`. |
| `confidence` | float 0–1 | ✔ | Keyakinan model. |
| `flagged_phrases[]` | array | ✔ | Frasa yang ditandai. `start` inklusif, `end` eksklusif, indeks karakter pada `input_text`. `level`: `low`/`medium`/`high`. |
| `features[]` | array | ✔ | Enam fitur tekstual. `membership` 0–1, `level` = himpunan fuzzy dominan, `matches` = kata pemicu. |
| `rules[]` | array | ✔ | Maksimal 3 aturan paling berpengaruh, urut dari `strength` terbesar. |
| `disclaimer` | string | – | Default disediakan aplikasi. |

## Kode fitur (`features[].id`)

| id | Label tampilan |
|---|---|
| `absolute_words` | Kata absolut & hiperbolik |
| `medical_claim` | Klaim medis / terapeutik |
| `unrealistic_time` | Klaim waktu tidak realistis |
| `authority_claim` | Klaim otoritas tanpa sumber |
| `superlative` | Superlatif tanpa bukti |
| `emotional_style` | Huruf kapital & seruan |

Kode ini juga dipakai untuk mengambil penjelasan di `assets/data/claim_insights.json` (field `feature_id`). Jika model menambah fitur baru, tambahkan juga entri penjelasannya di file tersebut dan ikonnya di `lib/shared/widgets/visuals.dart`.

## Aturan penulisan teks aturan fuzzy

Gunakan kata kunci huruf kapital agar diwarnai otomatis oleh `RuleCard`:
`JIKA`, `DAN`, `MAKA` (hijau tua), `TINGGI` (merah), `SEDANG` (kuning), `RENDAH` (hijau).
