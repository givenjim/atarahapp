// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_collaborations_id_accept_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeCollaborationsIdAcceptResponse
_$PostApiV1MeCollaborationsIdAcceptResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MeCollaborationsIdAcceptResponse(
  data: CollaborationDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MeCollaborationsIdAcceptResponseToJson(
  PostApiV1MeCollaborationsIdAcceptResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
