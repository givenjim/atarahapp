// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'set_setting_dto.g.dart';

@JsonSerializable()
class SetSettingDto {
  const SetSettingDto({required this.value, this.description});

  factory SetSettingDto.fromJson(Map<String, Object?> json) =>
      _$SetSettingDtoFromJson(json);

  /// The new value. It must be the same kind (string, number or boolean) as the current one.
  final dynamic value;
  final String? description;

  Map<String, Object?> toJson() => _$SetSettingDtoToJson(this);
}
