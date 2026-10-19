// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'project_link_dto.g.dart';

@JsonSerializable()
class ProjectLinkDto {
  const ProjectLinkDto({
    required this.id,
    required this.label,
    required this.url,
    this.embedUrl,
  });

  factory ProjectLinkDto.fromJson(Map<String, Object?> json) =>
      _$ProjectLinkDtoFromJson(json);

  final String id;
  final String label;
  final String url;

  /// Set for YouTube and Vimeo links: the address of the embedded player.
  final String? embedUrl;

  Map<String, Object?> toJson() => _$ProjectLinkDtoToJson(this);
}
