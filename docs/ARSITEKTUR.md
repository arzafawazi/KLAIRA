# Arsitektur Aplikasi Klaira

## Lapisan

```
┌─────────────────────────────────────────────────────────────┐
│  features/  (UI)   Splash · Onboarding · Home · Check ·     │
│                    Result · History · Education · Profile   │
│        │ membaca/menulis via Provider                       │
├────────▼────────────────────────────────────────────────────┤
│  state/AppState (ChangeNotifier)                            │
│  riwayat, tersimpan, onboarding, nama, preferensi           │
├────────┬────────────────────────────────────────────────────┤
│  data/repositories                                          │
│   ├─ AnalysisRepository (interface)                         │
│   │     └─ DummyAnalysisRepository → simulation/            │
│   └─ ContentRepository  → assets/data/*.json                │
├─────────────────────────────────────────────────────────────┤
│  data/models  (AnalysisResult = kontrak data model)         │
├─────────────────────────────────────────────────────────────┤
│  core/  theme (design system) · router · utils · constants  │
└─────────────────────────────────────────────────────────────┘
```

Prinsip yang dipakai:

- **Feature-first**: setiap kelompok layar punya folder sendiri, sehingga anggota tim bisa bekerja paralel tanpa konflik.
- **Bergantung pada interface**: layar tidak tahu apakah analisis berasal dari simulator atau API.
- **Data terpisah dari kode**: konten di JSON, token desain di `core/theme`.
- **Immutable model** + `copyWith`, state diubah hanya lewat method `AppState`.
- **Aksesibilitas**: status selalu ikon + teks + warna, label `Semantics`, target sentuh ≥ 44 px, skala teks hingga 130%.

## Rute (go_router)

| Path | Layar | Figma |
|---|---|---|
| `/` | SplashScreen | 01 Splash |
| `/onboarding` | OnboardingScreen | 02–04 Onboarding |
| `/home` | HomeScreen (tab 1) | 05 Beranda |
| `/history` | HistoryScreen (tab 2) | 11 Riwayat |
| `/education` | EducationScreen (tab 3) | 12 Edukasi |
| `/profile` | ProfileScreen (tab 4) | 14 Profil |
| `/check` · `/check?mode=link` | CheckScreen | 06 · 07 Cek Iklan |
| `/analyzing` (extra: `AnalysisRequest`) | AnalyzingScreen | 08 Menganalisis |
| `/result/:id` | ResultScreen | 09 Hasil Analisis |
| `/result/:id/claim/:featureId` | ClaimDetailScreen | 10 Detail Klaim |
| `/article/:id` | ArticleDetailScreen | 13 Detail Artikel |

Tab utama memakai `StatefulShellRoute.indexedStack` sehingga posisi scroll tiap tab terjaga. Layar turunan dibuka di navigator root sehingga *bottom navigation* tersembunyi, sesuai *user flow* di Figma.

## Design system: Figma → kode

| Figma (halaman 🎨 Design System) | Kode |
|---|---|
| Variabel `color/*` | `AppColors` (`core/theme/app_colors.dart`) |
| Variabel `space/*`, `radius/*` | `AppSpacing`, `AppRadius` |
| Text style `Display`, `Heading/*`, `Body/*`, `Caption`, `Overline` | `AppTypography.textTheme` (lihat tabel di file) |
| Komponen `Button` (Primary/Secondary/Ghost) | `FilledButton` / `OutlinedButton` / `TextButton` (gaya dari `AppTheme`) |
| `Status Badge` | `StatusBadge` |
| `Top Bar` | `AppBar` + `CircleIconButton` |
| `Bottom Nav` + tombol Cek | `MainShell` |
| `History Item` | `HistoryCard` |
| `Chip` | `ChoiceChip` (gaya dari `AppTheme.chipTheme`) |
| `Segmented Control` | `SegmentedButton` |
| `Brand/Logo Mark` | `KlairaLogo` |
| Gauge skor | `ScoreGauge` (`CustomPainter`) |
| Teks dengan frasa ditandai | `HighlightedAdText` (`Text.rich` + `TapGestureRecognizer`) |
| Grafik derajat keanggotaan | `MembershipChart` (`CustomPainter`) |
| Kartu aturan fuzzy | `RuleCard` |

## Responsif & adaptif

`lib/core/utils/responsive.dart` mengikuti *window size class* Material 3:

| Kelas | Lebar | Navigasi | Penyesuaian tata letak |
|---|---|---|---|
| `compact` | < 600 dp | Bottom bar + tombol Cek di tengah | Satu kolom, grid 2 kolom |
| `medium` | 600–839 dp | `NavigationRail` (label di bawah ikon) | Grid 3 kolom, Riwayat Terakhir berdampingan |
| `expanded` | ≥ 840 dp | `NavigationRail` diperluas + tombol "Cek Iklan" | Hasil Analisis dua kolom, Kamus Klaim 6 kolom |

- `ResponsiveCenter` membatasi lebar konten (720–1120 dp) agar baris teks tetap nyaman dibaca di tablet.
- `LayoutBuilder` dipakai di Hasil Analisis; `OrientationBuilder` di Onboarding (lanskap → ilustrasi & teks berdampingan).
- Orientasi tidak dikunci; diuji oleh `test/widget/responsive_test.dart` dan golden 15–19.

## Penyimpanan lokal (SharedPreferences)

| Key | Isi |
|---|---|
| `onboarding_done` | bool |
| `history_v1` | JSON array `AnalysisResult` |
| `user_name` | string |
| `edu_notification` | bool |

## Pengujian

| Jenis | File | Isi |
|---|---|---|
| Unit | `test/unit/overclaim_simulator_test.dart` | kategori Aman/Waspada/Overclaim, indeks frasa, 6 fitur, determinisme, round-trip JSON, batas skor |
| Widget | `test/widget/app_flow_test.dart` | onboarding pengguna baru; alur Beranda → Cek → Menganalisis → Hasil |
| Widget | `test/widget/responsive_test.dart` | breakpoint, bottom bar vs NavigationRail, onboarding lanskap, kolom grid adaptif |
| Golden | `test/golden/screens_golden_test.dart` | tangkapan layar 14 layar + 5 tablet/lanskap (jalankan dengan `--tags golden --run-skipped`) |
