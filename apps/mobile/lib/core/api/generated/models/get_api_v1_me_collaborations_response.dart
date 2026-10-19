// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'collaboration_dto.dart';

part 'get_api_v1_me_collaborations_response.g.dart';

@JsonSerializable()
class GetApiV1MeCollaborationsResponse {
  const GetApiV1MeCollaborationsResponse({required this.data, this.meta});

  factory GetApiV1MeCollaborationsResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1MeCollaborationsResponseFromJson(json);

  final List<CollaborationDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1MeCollaborationsResponseToJson(this);
}
