import 'package:flutter/foundation.dart';

/// Penjelasan edukatif untuk satu kategori klaim (dipakai di Detail Klaim
/// dan Kamus Klaim). Sumber: `assets/data/claim_insights.json`.
@immutable
class ClaimInsight {
  const ClaimInsight({
    required this.featureId,
    required this.title,
    required this.shortTitle,
    required this.description,
    required this.why,
    required this.examples,
    required this.betterClaims,
    required this.reference,
  });

  final String featureId;
  final String title;
  final String shortTitle;
  final String description;
  final String why;
  final List<String> examples;
  final List<String> betterClaims;
  final String reference;

  factory ClaimInsight.fromJson(Map<String, dynamic> json) => ClaimInsight(
        featureId: json['feature_id'] as String,
        title: json['title'] as String,
        shortTitle: json['short_title'] as String,
        description: json['description'] as String,
        why: json['why'] as String,
        examples: (json['examples'] as List<dynamic>).cast<String>(),
        betterClaims: (json['better_claims'] as List<dynamic>).cast<String>(),
        reference: json['reference'] as String,
      );
}

/// Blok isi artikel: paragraf biasa atau daftar bernomor.
@immutable
class ArticleBlock {
  const ArticleBlock.paragraph(this.text)
      : items = const [],
        heading = null;
  const ArticleBlock.list(this.items, {this.heading}) : text = null;

  final String? text;
  final String? heading;
  final List<ArticleListItem> items;

  bool get isList => items.isNotEmpty;

  factory ArticleBlock.fromJson(Map<String, dynamic> json) {
    if (json['type'] == 'list') {
      return ArticleBlock.list(
        (json['items'] as List<dynamic>).map((e) => ArticleListItem.fromJson(e as Map<String, dynamic>)).toList(),
        heading: json['heading'] as String?,
      );
    }
    return ArticleBlock.paragraph(json['text'] as String);
  }
}

@immutable
class ArticleListItem {
  const ArticleListItem({required this.title, required this.body});
  final String title;
  final String body;

  factory ArticleListItem.fromJson(Map<String, dynamic> json) =>
      ArticleListItem(title: json['title'] as String, body: json['body'] as String);
}

/// Artikel edukasi. Sumber: `assets/data/articles.json`.
@immutable
class Article {
  const Article({
    required this.id,
    required this.category,
    required this.title,
    required this.summary,
    required this.readMinutes,
    required this.icon,
    required this.tone,
    required this.blocks,
    required this.cover,
    this.featured = false,
  });

  final String id;
  final String category;
  final String title;
  final String summary;
  final int readMinutes;

  /// Nama ikon (dipetakan di `ArticleVisuals`).
  final String icon;

  /// `primary`, `safe`, atau `accent`.
  final String tone;
  final List<ArticleBlock> blocks;

  /// Path gambar sampul di `assets/images/articles/`.
  final String cover;
  final bool featured;

  factory Article.fromJson(Map<String, dynamic> json) => Article(
        id: json['id'] as String,
        category: json['category'] as String,
        title: json['title'] as String,
        summary: json['summary'] as String,
        readMinutes: json['read_minutes'] as int,
        icon: json['icon'] as String,
        tone: json['tone'] as String,
        featured: json['featured'] as bool? ?? false,
        cover: json['cover'] as String? ?? 'assets/images/articles/${json['id']}.jpg',
        blocks: (json['blocks'] as List<dynamic>).map((e) => ArticleBlock.fromJson(e as Map<String, dynamic>)).toList(),
      );
}

/// Contoh iklan untuk demo & data riwayat awal. Sumber: `assets/data/sample_ads.json`.
@immutable
class SampleAd {
  const SampleAd({
    required this.product,
    required this.source,
    required this.text,
    required this.daysAgo,
    this.url,
    this.store,
    this.price,
  });

  final String product;
  final String source;
  final String text;
  final int daysAgo;
  final String? url;
  final String? store;
  final String? price;

  factory SampleAd.fromJson(Map<String, dynamic> json) => SampleAd(
        product: json['product'] as String,
        source: json['source'] as String,
        text: json['text'] as String,
        daysAgo: json['days_ago'] as int? ?? 0,
        url: json['url'] as String?,
        store: json['store'] as String?,
        price: json['price'] as String?,
      );
}
