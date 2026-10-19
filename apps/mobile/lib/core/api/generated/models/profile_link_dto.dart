// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'profile_link_dto.g.dart';

@JsonSerializable()
class ProfileLinkDto {
  const ProfileLinkDto({
    required this.id,
    required this.label,
    required this.url,
  });

  factory ProfileLinkDto.fromJson(Map<String, Object?> json) =>
      _$ProfileLinkDtoFromJson(json);

  final String id;
  final String label;
  final String url;

  Map<String, Object?> toJson() => _$ProfileLinkDtoToJson(this);
}
