import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'bootstrap.dart';
import 'core/constants/app_info.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/analysis_repository.dart';
import 'data/repositories/content_repository.dart';
import 'state/app_state.dart';

class KlairaApp extends StatefulWidget {
  const KlairaApp({super.key, required this.deps});

  final AppDependencies deps;

  @override
  State<KlairaApp> createState() => _KlairaAppState();
}

class _KlairaAppState extends State<KlairaApp> {
  late final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ContentRepository>.value(value: widget.deps.content),
        Provider<AnalysisRepository>.value(value: widget.deps.analysis),
        ChangeNotifierProvider<AppState>.value(value: widget.deps.state),
      ],
      child: MaterialApp.router(
        title: AppInfo.name,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
        // Batasi skala teks agar layout tetap rapi, tetapi tetap aksesibel.
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(textScaler: mq.textScaler.clamp(maxScaleFactor: 1.3)),
            child: child!,
          );
        },
      ),
    );
  }
}
