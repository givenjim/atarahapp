// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_groups_ref_leave_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1GroupsRefLeaveResponse _$PostApiV1GroupsRefLeaveResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1GroupsRefLeaveResponse(
  data: GroupMembershipStateDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1GroupsRefLeaveResponseToJson(
  PostApiV1GroupsRefLeaveResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
