// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// Closing soon: URGENT is 7 days or fewer (Coral), SOON is 8 to 14 (Tangerine).
@JsonEnum()
enum OpportunityDtoUrgency {
  @JsonValue('URGENT')
  urgent('URGENT'),
  @JsonValue('SOON')
  soon('SOON'),
  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const OpportunityDtoUrgency(this.json);

  factory OpportunityDtoUrgency.fromJson(String json) => values.firstWhere(
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
  static List<OpportunityDtoUrgency> get $valuesDefined => values.where((value) => value != $unknown).toList();
}
