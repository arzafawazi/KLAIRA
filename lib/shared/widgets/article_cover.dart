import 'package:flutter/material.dart';

import '../../data/models/content.dart';
import 'visuals.dart';

/// Gambar sampul artikel dari `assets/images/articles/`.
///
/// Memakai [Image.asset] dengan `fit: BoxFit.cover`, `cacheWidth` agar hemat
/// memori, dan `errorBuilder` sehingga tetap tampil rapi bila file gambar
/// tidak ditemukan.
class ArticleCover extends StatelessWidget {
  const ArticleCover({super.key, required this.article, this.borderRadius, this.height});

  final Article article;
  final BorderRadius? borderRadius;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = Visuals.tone(article.tone);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final image = Image.asset(
      article.cover,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      cacheWidth: (600 * dpr).round(),
      semanticLabel: 'Sampul artikel ${article.title}',
      errorBuilder: (_, __, ___) => Container(
        height: height,
        color: bg,
        alignment: Alignment.center,
        child: Icon(Visuals.articleIcon(article.icon), color: fg, size: 40),
      ),
    );
    return borderRadius == null ? image : ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
