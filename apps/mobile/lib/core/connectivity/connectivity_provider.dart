import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

/// True while the device has some network connection. (Reachability of Atarah itself is reported by the
/// failures of real requests; this only drives the global offline banner.)
@Riverpod(keepAlive: true)
Stream<bool> isOnline(Ref ref) async* {
  final connectivity = Connectivity();
  bool online(List<ConnectivityResult> r) =>
      r.any((e) => e != ConnectivityResult.none);
  yield online(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(online).distinct();
}

/// True only when the device reports no connection at all. Actions that need the server ("Apply", "Post", "Book")
/// disable themselves and say so while this is true; reading what was saved still works. While the first reading is
/// pending it is false, so nothing flashes disabled.
final isOfflineProvider = Provider<bool>(
  (ref) => ref.watch(isOnlineProvider).value == false,
);
