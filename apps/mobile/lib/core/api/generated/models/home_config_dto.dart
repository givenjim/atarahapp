// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'home_config_dto.g.dart';

@JsonSerializable()
class HomeConfigDto {
  const HomeConfigDto({
    this.featuredArticleId,
    this.featuredArticleTitle,
    this.updatedAt,
  });

  factory HomeConfigDto.fromJson(Map<String, Object?> json) =>
      _$HomeConfigDtoFromJson(json);

  final String? featuredArticleId;
  final String? featuredArticleTitle;
  final DateTime? updatedAt;

  Map<String, Object?> toJson() => _$HomeConfigDtoToJson(this);
}
