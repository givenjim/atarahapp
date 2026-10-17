// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'reactivate_user_dto.g.dart';

@JsonSerializable()
class ReactivateUserDto {
  const ReactivateUserDto({this.reason});

  factory ReactivateUserDto.fromJson(Map<String, Object?> json) =>
      _$ReactivateUserDtoFromJson(json);

  final String? reason;

  Map<String, Object?> toJson() => _$ReactivateUserDtoToJson(this);
}
