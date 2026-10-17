// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'set_avatar_dto.g.dart';

@JsonSerializable()
class SetAvatarDto {
  const SetAvatarDto({required this.mediaId});

  factory SetAvatarDto.fromJson(Map<String, Object?> json) =>
      _$SetAvatarDtoFromJson(json);

  /// A READY image the member uploaded through /media (PUBLIC).
  final String mediaId;

  Map<String, Object?> toJson() => _$SetAvatarDtoToJson(this);
}
