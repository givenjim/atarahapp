// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum ModerationAction {
  @JsonValue('NO_ACTION')
  noAction('NO_ACTION'),
  @JsonValue('WARN_USER')
  warnUser('WARN_USER'),
  @JsonValue('HIDE_CONTENT')
  hideContent('HIDE_CONTENT'),
  @JsonValue('REMOVE_CONTENT')
  removeContent('REMOVE_CONTENT'),
  @JsonValue('RESTORE_CONTENT')
  restoreContent('RESTORE_CONTENT'),
  @JsonValue('RESTRICT_ACCOUNT')
  restrictAccount('RESTRICT_ACCOUNT'),
  @JsonValue('SUSPEND_ACCOUNT')
  suspendAccount('SUSPEND_ACCOUNT'),
  @JsonValue('ESCALATE')
  escalate('ESCALATE'),
  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const ModerationAction(this.json);

  factory ModerationAction.fromJson(String json) => values.firstWhere(
        (e) => e.json == json,
        orElse: () => $unknown,
      );

  final String? json;
  String toJson() {
    final value = json;
    if (value == null) {
      throw StateError('Cannot convert enum value with null JSON representation to String. '
          'This usually happens for \$unknown or @JsonValue(null) entries.');
    }
    return value as String;
  }

  @override
  String toString() => json?.toString() ?? super.toString();
  /// Returns all defined enum values excluding the $unknown value.
  static List<ModerationAction> get $valuesDefined => values.where((value) => value != $unknown).toList();
}
