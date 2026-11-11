# Vibe Coding di Project Klaira

Dokumen ini mencatat cara tim memakai asisten AI (*vibe coding*) secara terkendali selama
pengembangan antarmuka Klaira: AI dipakai untuk mempercepat draf, tetapi **setiap keluaran
ditinjau, dijalankan, dan diuji oleh anggota tim sebelum di-*merge***.

---

## 1. Prinsip

| Prinsip | Penerapan di Klaira |
|---|---|
| **Manusia tetap pemilik keputusan** | AI hanya membuat draf. Struktur folder, desain, dan kontrak data ditentukan tim (Figma + `docs/`). |
| **Prompt yang spesifik** | Prompt selalu menyebut: konteks file, widget yang diharapkan, token desain (`AppColors`, `AppSpacing`), dan batasan (*no backend*, data dummy). |
| **Verifikasi otomatis** | Setiap keluaran wajib lolos `flutter analyze` (aturan `analysis_options.yaml`) dan `flutter test`. |
| **Iterasi kecil** | Satu prompt = satu widget/fitur. Perubahan besar dipecah agar mudah ditinjau. |
| **Tidak menyalin buta** | Kode yang tidak dipahami tidak di-*merge*. Peninjau wajib bisa menjelaskan setiap baris. |

---

## 2. Alur kerja

```
 1. Tulis prompt        →  konteks + tujuan + batasan + contoh keluaran
 2. Generate draf       →  AI menghasilkan kode/data
 3. Tinjau manual       →  cocokkan dengan Figma & checklist (bagian 4)
 4. Jalankan            →  flutter analyze  →  flutter test  →  flutter run
 5. Refactor            →  rapikan nama, pindahkan ke widget reusable, pakai token desain
 6. Catat               →  isi log prompt (bagian 3)
```

---

## 3. Log prompt (ringkas)

| # | Tujuan | Ringkasan prompt | Hasil tinjauan & perbaikan manual |
|---|---|---|---|
| P-01 | Data dummy iklan | “Buat 8 contoh deskripsi produk skincare berbahasa Indonesia dari Shopee/Tokopedia/TikTok Shop; campurkan klaim wajar dan berlebihan; format JSON sesuai `sample_ads.json`.” | Nama merek diganti fiktif, klaim disesuaikan dengan 6 kategori di Tabel 2.1 proposal, field `platform` diseragamkan. |
| P-02 | Kamus klaim | “Untuk 6 kategori klaim (absolut, medis, waktu, otoritas, superlatif, emosional), tulis penjelasan singkat, 3 contoh kata pemicu, dan 2 contoh klaim yang wajar.” | Dasar acuan dicek ulang ke Peraturan BPOM; kalimat dipersingkat agar muat di kartu. |
| P-03 | Leksikon simulator | “Daftar frasa pemicu per kategori untuk pencocokan regex, huruf kecil, tanpa duplikat.” | Frasa ambigu (mis. “aman”) dihapus karena memicu *false positive*; ditambah unit test. |
| P-04 | Widget reusable | “Buat `Pill` dan `StatusBadge` yang memakai `AppColors` & `AppRadius`, mendukung ikon opsional.” | Ditambah `Semantics`; warna status selalu disertai ikon & teks (WCAG). |
| P-05 | Format tanggal | “Fungsi format ‘Hari ini, 10.24’ / ‘Kemarin’ / ‘12 Okt’ memakai `intl` locale `id_ID`.” | Format jam disesuaikan ke gaya Indonesia (`10.24`), ditambah fungsi pengelompokan riwayat (Hari ini / Kemarin / Minggu ini / Lebih lama). |
| P-06 | Refactor lint | “Perbaiki peringatan `unawaited_futures` dan `prefer_const_constructors` pada file berikut tanpa mengubah perilaku.” | Diterima setelah `flutter test` tetap hijau. |
| P-07 | Test | “Buat widget test alur Beranda → Cek → Menganalisis → Hasil memakai `testDeps()`.” | Ditambah `pump` untuk animasi; nilai durasi dibuat dapat diatur agar test stabil. |
| P-08 | Dokumentasi | “Draf README: cara menjalankan, struktur folder, troubleshooting.” | Disesuaikan dengan perintah yang benar-benar dipakai tim dan diuji di laptop anggota. |

---

## 4. Checklist tinjauan kode hasil AI

- [ ] Memakai token desain (`AppColors`, `AppSpacing`, `AppRadius`, `textTheme`) — **tidak ada warna/ukuran *hard-coded*** baru.
- [ ] Widget yang dipakai lebih dari sekali dipindah ke `lib/shared/widgets/`.
- [ ] Ada `const` di tempat yang memungkinkan; tidak ada `print`.
- [ ] Teks dan ikon memiliki label aksesibilitas bila perlu (`Semantics`, `tooltip`, `semanticLabel`).
- [ ] Tidak ada *overflow* di layar 360 dp, lanskap, dan tablet.
- [ ] `flutter analyze` → *No issues found*; `flutter test` → semua lulus.
- [ ] Tidak ada kunci API, data pribadi, atau aset berlisensi tidak jelas.

---

## 5. Batasan penggunaan AI

- AI **tidak** dipakai untuk mengambil keputusan desain akhir — rujukan tetap Figma.
- Keluaran model neurofuzzy pada aplikasi adalah **simulasi** (`lib/data/simulation/`) yang mengikuti
  kontrak data di `docs/KONTRAK_DATA.md`; AI tidak dipakai untuk mengarang hasil penelitian.
- Semua teks edukasi diperiksa ulang terhadap sumber yang dikutip di proposal.
