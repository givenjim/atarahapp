// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'embed_hosts_dto.dart';

part 'get_api_v1_admin_learning_embed_hosts_response.g.dart';

@JsonSerializable()
class GetApiV1AdminLearningEmbedHostsResponse {
  const GetApiV1AdminLearningEmbedHostsResponse({
    required this.data,
    this.meta,
  });

  factory GetApiV1AdminLearningEmbedHostsResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1AdminLearningEmbedHostsResponseFromJson(json);

  final EmbedHostsDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1AdminLearningEmbedHostsResponseToJson(this);
}
