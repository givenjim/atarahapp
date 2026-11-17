// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_membership_state_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupMembershipStateDto _$GroupMembershipStateDtoFromJson(
  Map<String, dynamic> json,
) => GroupMembershipStateDto(
  groupId: json['groupId'] as String,
  joined: json['joined'] as bool,
  memberCount: json['memberCount'] as num,
);

Map<String, dynamic> _$GroupMembershipStateDtoToJson(
  GroupMembershipStateDto instance,
) => <String, dynamic>{
  'groupId': instance.groupId,
  'joined': instance.joined,
  'memberCount': instance.memberCount,
};
