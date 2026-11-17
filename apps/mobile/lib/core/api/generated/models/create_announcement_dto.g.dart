// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_announcement_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateAnnouncementDto _$CreateAnnouncementDtoFromJson(
  Map<String, dynamic> json,
) => CreateAnnouncementDto(
  body: json['body'] as String,
  groupId: json['groupId'] as String?,
);

Map<String, dynamic> _$CreateAnnouncementDtoToJson(
  CreateAnnouncementDto instance,
) => <String, dynamic>{'body': instance.body, 'groupId': instance.groupId};
