// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'embed_hosts_dto.g.dart';

@JsonSerializable()
class EmbedHostsDto {
  const EmbedHostsDto({
    required this.hosts,
  });
  
  factory EmbedHostsDto.fromJson(Map<String, Object?> json) => _$EmbedHostsDtoFromJson(json);
  
  final List<String> hosts;

  Map<String, Object?> toJson() => _$EmbedHostsDtoToJson(this);
}
