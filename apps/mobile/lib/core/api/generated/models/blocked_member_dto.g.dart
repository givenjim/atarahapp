// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocked_member_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockedMemberDto _$BlockedMemberDtoFromJson(Map<String, dynamic> json) =>
    BlockedMemberDto(
      userId: json['userId'] as String,
      handle: json['handle'] as String?,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      blockedAt: DateTime.parse(json['blockedAt'] as String),
    );

Map<String, dynamic> _$BlockedMemberDtoToJson(BlockedMemberDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'handle': instance.handle,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'blockedAt': instance.blockedAt.toIso8601String(),
    };
