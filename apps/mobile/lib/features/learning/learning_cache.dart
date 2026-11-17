import 'dart:convert';

import '../../core/api/generated/export.dart';
import '../../core/storage/secure_storage.dart';

/// A read-only copy of the Skill Labs the member is in the middle of, kept for offline reading: the course
/// detail, the lessons they opened and where they stopped. Nothing here is ever sent back; when the member is
/// online again the server's copy replaces it. Every method swallows storage errors, because a cache must never
/// break the screen it serves.
class LearningCache {
  LearningCache(this._store);

  final KeyValueStore _store;

  static String _detailKey(String id) => 'learning.detail.$id';
  static String _lessonKey(String id) => 'learning.lesson.$id';
  static String _positionKey(String id) => 'learning.position.$id';

  Future<void> saveDetail(LearningDetailDto d) async {
    // Only what the member is actually learning is kept.
    if (d.course?.enrolled != true && d.itemProgress == null) return;
    await _write(_detailKey(d.id), d.toJson());
  }

  Future<LearningDetailDto?> detail(String id) async {
    final json = await _read(_detailKey(id));
    return json == null ? null : _parse(() => LearningDetailDto.fromJson(json));
  }

  Future<void> saveLesson(LessonDto l) => _write(_lessonKey(l.id), l.toJson());

  Future<LessonDto?> lesson(String id) async {
    final json = await _read(_lessonKey(id));
    return json == null ? null : _parse(() => LessonDto.fromJson(json));
  }

  /// Where the member got to in a lesson, whole seconds. Only moves forward.
  Future<void> savePosition(String lessonId, int seconds) async {
    final current = await position(lessonId) ?? 0;
    if (seconds <= current) return;
    try {
      await _store.write(_positionKey(lessonId), '$seconds');
    } on Object {
      // A cache miss later is harmless.
    }
  }

  Future<int?> position(String lessonId) async {
    try {
      return int.tryParse(await _store.read(_positionKey(lessonId)) ?? '');
    } on Object {
      return null;
    }
  }

  Future<void> _write(String key, Map<String, Object?> json) async {
    try {
      await _store.write(key, jsonEncode(json));
    } on Object {
      // See the class comment.
    }
  }

  Future<Map<String, Object?>?> _read(String key) async {
    try {
      final raw = await _store.read(key);
      if (raw == null) return null;
      final decoded = jsonDecode(raw);
      return decoded is Map<String, Object?> ? decoded : null;
    } on Object {
      return null;
    }
  }

  T? _parse<T>(T Function() build) {
    try {
      return build();
    } on Object {
      return null;
    }
  }
}
