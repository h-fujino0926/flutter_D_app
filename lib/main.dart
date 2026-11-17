import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';
import 'core/prefs/local_prefs.dart';

/// 起動方法：
///   flutter run -d windows --dart-define-from-file=env.json
Future<void> main() async {
  final prefs = await bootstrap();
  if (prefs == null) {
    runApp(const MissingEnvApp());
    return;
  }
  runApp(
    ProviderScope(
      overrides: [localPrefsProvider.overrideWithValue(prefs)],
      child: const FusenApp(),
    ),
  );
}
