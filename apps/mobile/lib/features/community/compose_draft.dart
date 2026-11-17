import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/storage/secure_storage.dart';

/// What the member has typed in the composer and not yet posted. Photos and videos are not kept: they live
/// on the phone until they are uploaded, and uploading happens when the member picks them.
class ComposeDraft {
  const ComposeDraft({
    this.type = 'UPDATE',
    this.body = '',
    this.audience = 'MEMBERS',
    this.groupId,
    this.groupName,
    this.linkUrl,
  });

  /// A `PostType` JSON value.
  final String type;
  final String body;

  /// `MEMBERS`, `PUBLIC`, `CONNECTIONS` or `GROUP`.
  final String audience;
  final String? groupId;
  final String? groupName;
  final String? linkUrl;

  bool get isEmpty => body.trim().isEmpty && linkUrl == null;

  Map<String, Object?> toJson() => {
    'type': type,
    'body': body,
    'audience': audience,
    'groupId': groupId,
    'groupName': groupName,
    'linkUrl': linkUrl,
  };

  static ComposeDraft? tryParse(String? raw) {
    if (raw == null) return null;
    try {
      final j = jsonDecode(raw);
      if (j is! Map) return null;
      return ComposeDraft(
        type: j['type'] as String? ?? 'UPDATE',
        body: j['body'] as String? ?? '',
        audience: j['audience'] as String? ?? 'MEMBERS',
        groupId: j['groupId'] as String?,
        groupName: j['groupName'] as String?,
        linkUrl: j['linkUrl'] as String?,
      );
    } on Object {
      return null;
    }
  }
}

/// Keeps one draft per signed-in member on the phone. Storage problems never get in the member's way: a
/// draft that cannot be saved or read is simply not there.
class ComposeDraftStore {
  ComposeDraftStore(this._store);

  final KeyValueStore _store;

  String _key(String userId) => 'community.compose.draft.$userId';

  Future<ComposeDraft?> load(String userId) async {
    try {
      return ComposeDraft.tryParse(await _store.read(_key(userId)));
    } on Object {
      return null;
    }
  }

  Future<void> save(String userId, ComposeDraft draft) async {
    try {
      if (draft.isEmpty) {
        await _store.delete(_key(userId));
      } else {
        await _store.write(_key(userId), jsonEncode(draft.toJson()));
      }
    } on Object {
      // Nothing to do: the text is still on screen.
    }
  }

  Future<void> clear(String userId) async {
    try {
      await _store.delete(_key(userId));
    } on Object {
      // See save.
    }
  }
}

final composeDraftStoreProvider = Provider<ComposeDraftStore>(
  (ref) => ComposeDraftStore(ref.watch(keyValueStoreProvider)),
);
