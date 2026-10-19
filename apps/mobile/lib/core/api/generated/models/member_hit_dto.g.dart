// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_hit_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberHitDto _$MemberHitDtoFromJson(Map<String, dynamic> json) => MemberHitDto(
  userId: json['userId'] as String,
  displayName: json['displayName'] as String,
  handle: json['handle'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  discipline: json['discipline'] as String?,
);

Map<String, dynamic> _$MemberHitDtoToJson(MemberHitDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'displayName': instance.displayName,
      'handle': instance.handle,
      'avatarUrl': instance.avatarUrl,
      'discipline': instance.discipline,
    };
