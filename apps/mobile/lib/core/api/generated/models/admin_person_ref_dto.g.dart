// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_person_ref_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminPersonRefDto _$AdminPersonRefDtoFromJson(Map<String, dynamic> json) =>
    AdminPersonRefDto(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      handle: json['handle'] as String?,
    );

Map<String, dynamic> _$AdminPersonRefDtoToJson(AdminPersonRefDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'handle': instance.handle,
    };
