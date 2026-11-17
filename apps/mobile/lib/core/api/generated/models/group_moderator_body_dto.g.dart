// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_moderator_body_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupModeratorBodyDto _$GroupModeratorBodyDtoFromJson(
  Map<String, dynamic> json,
) => GroupModeratorBodyDto(
  userId: json['userId'] as String,
  role: json['role'] == null
      ? GroupStaffRole.moderator
      : GroupStaffRole.fromJson(json['role'] as String),
);

Map<String, dynamic> _$GroupModeratorBodyDtoToJson(
  GroupModeratorBodyDto instance,
) => <String, dynamic>{'userId': instance.userId, 'role': instance.role};
