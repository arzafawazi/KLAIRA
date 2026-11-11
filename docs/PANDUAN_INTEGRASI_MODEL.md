# Panduan Integrasi dengan Model Neurofuzzy

Prototipe memakai `DummyAnalysisRepository` (simulasi lokal). Saat model ANFIS dari penelitian NLP sudah bisa diakses lewat API, ikuti langkah berikut. **Tidak ada layar yang perlu diubah** karena semua layar hanya bergantung pada interface `AnalysisRepository` dan model `AnalysisResult`.

```
CheckScreen ──► AnalyzingScreen ──► AnalysisRepository.analyze() ──► AnalysisResult ──► ResultScreen
                                         ▲
                     DummyAnalysisRepository (sekarang)  /  ApiAnalysisRepository (nanti)
```

## 1. Siapkan endpoint model

Contoh endpoint sederhana (Python FastAPI/Flask) yang membungkus model:

```
POST /analyze
Body:     { "text": "...", "source": "shopee", "product": "..." }
Response: JSON sesuai docs/KONTRAK_DATA.md
```

Saat pengembangan di emulator Android, alamat laptop adalah `http://10.0.2.2:<port>`.

## 2. Tambahkan package HTTP

```bash
flutter pub add http
```

## 3. Buat `lib/data/repositories/api_analysis_repository.dart`

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/analysis_result.dart';
import 'analysis_repository.dart';

class ApiAnalysisRepository implements AnalysisRepository {
  ApiAnalysisRepository({required this.baseUrl, required this.fallback, http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  final AnalysisRepository fallback; // untuk fetchFromLink selama belum ada scraper
  final http.Client _client;

  @override
  Future<AnalysisResult> analyze(AnalysisRequest request) async {
    try {
      final res = await _client
          .post(
            Uri.parse('$baseUrl/analyze'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'text': request.text,
              'source': request.source.id,
              'product': request.productName,
            }),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) {
        throw AnalysisException('Server model merespons ${res.statusCode}.');
      }
      return AnalysisResult.fromJson(jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
    } on AnalysisException {
      rethrow;
    } on Object {
      throw const AnalysisException('Tidak dapat terhubung ke server model.');
    }
  }

  @override
  Future<LinkPreview> fetchFromLink(String url) => fallback.fetchFromLink(url);
}
```

## 4. Ganti satu baris di `lib/bootstrap.dart`

```dart
// Sebelum
final analysis = DummyAnalysisRepository(content: content);

// Sesudah
final analysis = ApiAnalysisRepository(
  baseUrl: 'http://10.0.2.2:8000',
  fallback: DummyAnalysisRepository(content: content),
);
```

## 5. Izin internet (Android rilis)

Tambahkan di `android/app/src/main/AndroidManifest.xml` (di luar tag `<application>`):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Untuk server lokal tanpa HTTPS, tambahkan juga `android:usesCleartextTraffic="true"` pada tag `<application>` (hanya untuk pengembangan).

## 6. Uji

- Jalankan `flutter test` — test simulator tetap lulus karena simulator tidak dihapus.
- Bandingkan hasil API dan simulator untuk teks contoh yang sama sebagai uji kewajaran.
- Pastikan indeks `start`/`end` frasa dari model mengacu ke teks yang sama persis dengan `input_text`.
