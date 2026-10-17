// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'reset_dto.g.dart';

@JsonSerializable()
class ResetDto {
  const ResetDto({required this.reset});

  factory ResetDto.fromJson(Map<String, Object?> json) =>
      _$ResetDtoFromJson(json);

  final bool reset;

  Map<String, Object?> toJson() => _$ResetDtoToJson(this);
}
