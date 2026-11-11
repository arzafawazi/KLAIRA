import 'package:flutter/foundation.dart';

import '../models/analysis_result.dart';
import '../models/enums.dart';
import '../simulation/overclaim_simulator.dart';
import 'content_repository.dart';

/// Pratinjau deskripsi produk yang diambil dari tautan e-commerce.
@immutable
class LinkPreview {
  const LinkPreview({
    required this.url,
    required this.product,
    required this.store,
    required this.price,
    required this.source,
    required this.description,
  });

  final String url;
  final String product;
  final String store;
  final String price;
  final AdSource source;
  final String description;
}

/// Gagal mengambil / menganalisis. Pesannya aman ditampilkan ke pengguna.
class AnalysisException implements Exception {
  const AnalysisException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Kontrak sumber analisis.
///
/// Prototipe memakai [DummyAnalysisRepository]. Saat model neurofuzzy siap,
/// buat implementasi baru (mis. `ApiAnalysisRepository`) yang memanggil
/// endpoint model, lalu ganti satu baris di `lib/bootstrap.dart`.
/// Lihat `docs/PANDUAN_INTEGRASI_MODEL.md`.
abstract interface class AnalysisRepository {
  /// Menganalisis teks iklan dan mengembalikan hasil sesuai kontrak data.
  Future<AnalysisResult> analyze(AnalysisRequest request);

  /// Mengambil deskripsi produk dari tautan e-commerce.
  Future<LinkPreview> fetchFromLink(String url);
}

/// Implementasi dummy: menjalankan [OverclaimSimulator] secara lokal dengan
/// jeda buatan agar alur "Menganalisis" terasa nyata.
class DummyAnalysisRepository implements AnalysisRepository {
  DummyAnalysisRepository({
    required ContentRepository content,
    this.simulator = const OverclaimSimulator(),
    this.latency = const Duration(milliseconds: 2400),
    this.linkLatency = const Duration(milliseconds: 1200),
  }) : _content = content;

  final ContentRepository _content;
  final OverclaimSimulator simulator;
  final Duration latency;
  final Duration linkLatency;

  @override
  Future<AnalysisResult> analyze(AnalysisRequest request) async {
    if (request.text.trim().length < 20) {
      throw const AnalysisException('Teks terlalu pendek untuk dianalisis.');
    }
    await Future<void>.delayed(latency);
    return simulator.analyze(request, id: DateTime.now().microsecondsSinceEpoch.toString());
  }

  @override
  Future<LinkPreview> fetchFromLink(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const AnalysisException('Tautan tidak valid. Pastikan diawali https://');
    }
    final source = AdSource.fromUrl(url);
    if (source == AdSource.other) {
      throw const AnalysisException('Saat ini hanya mendukung tautan Shopee, Tokopedia, dan TikTok Shop.');
    }
    await Future<void>.delayed(linkLatency);

    // Simulasi: kembalikan contoh iklan dari platform yang sama.
    final candidates = _content.sampleAds.where((a) => a.source == source.id).toList();
    final ad = candidates.isNotEmpty ? candidates.first : _content.demoAd;
    return LinkPreview(
      url: url.trim(),
      product: ad.product,
      store: ad.store ?? 'Toko Resmi',
      price: ad.price ?? '-',
      source: source,
      description: ad.text,
    );
  }
}
