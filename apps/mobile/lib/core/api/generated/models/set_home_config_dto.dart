// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'set_home_config_dto.g.dart';

@JsonSerializable()
class SetHomeConfigDto {
  const SetHomeConfigDto({this.featuredArticleId});

  factory SetHomeConfigDto.fromJson(Map<String, Object?> json) =>
      _$SetHomeConfigDtoFromJson(json);

  /// A published article. Null un-pins.
  final String? featuredArticleId;

  Map<String, Object?> toJson() => _$SetHomeConfigDtoToJson(this);
}
