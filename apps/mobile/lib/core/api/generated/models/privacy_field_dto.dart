// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'privacy_field.dart';
import 'visibility.dart';

part 'privacy_field_dto.g.dart';

@JsonSerializable()
class PrivacyFieldDto {
  const PrivacyFieldDto({
    required this.field,
    required this.label,
    required this.visibility,
    required this.defaultVisibility,
  });
  
  factory PrivacyFieldDto.fromJson(Map<String, Object?> json) => _$PrivacyFieldDtoFromJson(json);
  
  final PrivacyField field;
  final String label;
  final Visibility visibility;
  final Visibility defaultVisibility;

  Map<String, Object?> toJson() => _$PrivacyFieldDtoToJson(this);
}
