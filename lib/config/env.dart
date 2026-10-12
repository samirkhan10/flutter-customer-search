import 'package:flutter/foundation.dart';

class Env {
  Env._();

  // flutter run --dart-define=API_BASE_URL=http://192.168.1.20:3001
  static const _override = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_override.isNotEmpty) return _override;
    // Android emulator reaches the host machine through 10.0.2.2
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3001';
    }
    return 'http://localhost:3001';
  }
}
