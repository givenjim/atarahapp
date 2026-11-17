// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_groups_ref_join_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1GroupsRefJoinResponse _$PostApiV1GroupsRefJoinResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1GroupsRefJoinResponse(
  data: GroupMembershipStateDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1GroupsRefJoinResponseToJson(
  PostApiV1GroupsRefJoinResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
