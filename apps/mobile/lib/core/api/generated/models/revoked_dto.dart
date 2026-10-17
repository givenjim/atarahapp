// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'revoked_dto.g.dart';

@JsonSerializable()
class RevokedDto {
  const RevokedDto({required this.revoked});

  factory RevokedDto.fromJson(Map<String, Object?> json) =>
      _$RevokedDtoFromJson(json);

  final bool revoked;

  Map<String, Object?> toJson() => _$RevokedDtoToJson(this);
}
