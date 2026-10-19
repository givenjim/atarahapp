// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'collaboration_dto.dart';

part 'post_api_v1_me_collaborations_id_accept_response.g.dart';

@JsonSerializable()
class PostApiV1MeCollaborationsIdAcceptResponse {
  const PostApiV1MeCollaborationsIdAcceptResponse({
    required this.data,
    this.meta,
  });

  factory PostApiV1MeCollaborationsIdAcceptResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1MeCollaborationsIdAcceptResponseFromJson(json);

  final CollaborationDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1MeCollaborationsIdAcceptResponseToJson(this);
}
