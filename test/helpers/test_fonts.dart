import 'dart:io';

import 'package:flutter/services.dart';

/// Memuat font Plus Jakarta Sans & Material Icons agar tata letak di test
/// sama dengan di perangkat (bukan font kotak bawaan test).
Future<void> loadAppFonts() async {
  final jakarta = FontLoader('PlusJakartaSans');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    jakarta.addFont(_read('assets/fonts/PlusJakartaSans-$w.ttf'));
  }
  await jakarta.load();

  // Cadangan glyph (μ, dll.) — di Android dipenuhi oleh font sistem Roboto.
  const dejavu = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf';
  if (File(dejavu).existsSync()) {
    await (FontLoader('Roboto')..addFont(_read(dejavu))).load();
  }

  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null) {
    final icons = File('$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
    if (icons.existsSync()) {
      await (FontLoader('MaterialIcons')..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())))).load();
    }
  }
}

Future<ByteData> _read(String path) async => ByteData.sublistView(await File(path).readAsBytes());
