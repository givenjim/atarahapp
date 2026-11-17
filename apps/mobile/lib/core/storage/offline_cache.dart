import 'dart:convert';

import 'secure_storage.dart';

/// A read-only copy of the few things the member can still read without a connection: their Passport and their
/// saved opportunities. Kept per member (the key carries the member id), never sent anywhere, replaced by the
/// server's copy as soon as a request succeeds, and every method swallows storage errors because a cache must never
/// break the screen it serves.
class OfflineCache {
  OfflineCache(this._store, this._memberId);

  final KeyValueStore _store;
  final String? _memberId;

  String _key(String name) => 'offline.${_memberId ?? 'anon'}.$name';

  Future<void> write(String name, Object json) async {
    if (_memberId == null) return;
    try {
      await _store.write(_key(name), jsonEncode(json));
    } on Object {
      // A cache miss later is harmless.
    }
  }

  /// The stored JSON (a map or a list), or null when nothing is stored or it cannot be read.
  Future<Object?> read(String name) async {
    if (_memberId == null) return null;
    try {
      final raw = await _store.read(_key(name));
      return raw == null ? null : jsonDecode(raw) as Object?;
    } on Object {
      return null;
    }
  }
}
