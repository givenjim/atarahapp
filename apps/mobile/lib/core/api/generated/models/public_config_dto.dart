// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'public_config_dto.g.dart';

@JsonSerializable()
class PublicConfigDto {
  const PublicConfigDto({required this.googleSignIn});

  factory PublicConfigDto.fromJson(Map<String, Object?> json) =>
      _$PublicConfigDtoFromJson(json);

  /// Show "Continue with Google" only when true.
  final bool googleSignIn;

  Map<String, Object?> toJson() => _$PublicConfigDtoToJson(this);
}
