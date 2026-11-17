import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';

/// 起動方法：
///   flutter run -d windows --dart-define-from-file=env.json
Future<void> main() async {
  final ready = await bootstrap();
  if (!ready) {
    runApp(const MissingEnvApp());
    return;
  }
  runApp(const ProviderScope(child: FusenApp()));
}
