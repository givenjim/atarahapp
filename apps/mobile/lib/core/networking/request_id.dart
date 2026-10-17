import 'dart:math';

final Random _rng = Random.secure();

/// 128-bit random id, hex encoded. Sent as `X-Request-Id` so a failing request can be found in backend logs.
String newRequestId() {
  final bytes = List<int>.generate(16, (_) => _rng.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
