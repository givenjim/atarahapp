import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_notice.g.dart';

/// A one-time message to show after navigation, for example "You were signed out on your other devices".
/// The shell shows it once and clears it.
@Riverpod(keepAlive: true)
class AppNotice extends _$AppNotice {
  @override
  String? build() => null;

  void show(String message) => state = message;
  void clear() => state = null;
}
