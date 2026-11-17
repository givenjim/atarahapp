// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'privacy_field.dart';
import 'visibility.dart';

part 'update_privacy_dto.g.dart';

@JsonSerializable()
class UpdatePrivacyDto {
  const UpdatePrivacyDto({required this.field, required this.visibility});

  factory UpdatePrivacyDto.fromJson(Map<String, Object?> json) =>
      _$UpdatePrivacyDtoFromJson(json);

  final PrivacyField field;
  final Visibility visibility;

  Map<String, Object?> toJson() => _$UpdatePrivacyDtoToJson(this);
}
