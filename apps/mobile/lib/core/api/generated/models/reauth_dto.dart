// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'reauth_dto.g.dart';

@JsonSerializable()
class ReauthDto {
  const ReauthDto({required this.reauthenticatedUntil});

  factory ReauthDto.fromJson(Map<String, Object?> json) =>
      _$ReauthDtoFromJson(json);

  final DateTime reauthenticatedUntil;

  Map<String, Object?> toJson() => _$ReauthDtoToJson(this);
}
