// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_group_moderator_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminGroupModeratorDto _$AdminGroupModeratorDtoFromJson(
  Map<String, dynamic> json,
) => AdminGroupModeratorDto(
  person: AdminPersonRefDto.fromJson(json['person'] as Map<String, dynamic>),
  role: GroupStaffRole.fromJson(json['role'] as String),
);

Map<String, dynamic> _$AdminGroupModeratorDtoToJson(
  AdminGroupModeratorDto instance,
) => <String, dynamic>{'person': instance.person, 'role': instance.role};
