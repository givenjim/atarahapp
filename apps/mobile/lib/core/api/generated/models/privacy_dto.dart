// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'privacy_field_dto.dart';

part 'privacy_dto.g.dart';

@JsonSerializable()
class PrivacyDto {
  const PrivacyDto({
    required this.fields,
  });
  
  factory PrivacyDto.fromJson(Map<String, Object?> json) => _$PrivacyDtoFromJson(json);
  
  final List<PrivacyFieldDto> fields;

  Map<String, Object?> toJson() => _$PrivacyDtoToJson(this);
}
