import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:sound_wave/src/features/waves/presentations/select_media_page.dart';

import 'features/app_startup/presentation/app_startup_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  MyApp.initialize({super.key}) {
    // init();
    runApp(ProviderScope(child: MyApp()));
  }

  Future<void> init() async {
    Logger.root.level = kDebugMode ? Level.FINE : Level.INFO;
    Logger.root.onRecord.listen((record) {
      log(
        record.message,
        time: record.time,
        level: record.level.value,
        name: record.loggerName,
        zone: record.zone,
        error: record.error,
        stackTrace: record.stackTrace,
      );
    });
    WidgetsFlutterBinding.ensureInitialized();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sound Wave',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
      ),
      home: AppStartupPage(onLoaded: (_) => const SelectMediaPage()),
    );
  }
}
