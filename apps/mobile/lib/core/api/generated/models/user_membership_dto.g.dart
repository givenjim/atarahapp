// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_membership_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserMembershipDto _$UserMembershipDtoFromJson(Map<String, dynamic> json) =>
    UserMembershipDto(
      plan: json['plan'] as String,
      status: json['status'] as String,
      source: json['source'] as String,
      startsAt: DateTime.parse(json['startsAt'] as String),
      currentPeriodEnd: json['currentPeriodEnd'] == null
          ? null
          : DateTime.parse(json['currentPeriodEnd'] as String),
    );

Map<String, dynamic> _$UserMembershipDtoToJson(UserMembershipDto instance) =>
    <String, dynamic>{
      'plan': instance.plan,
      'status': instance.status,
      'source': instance.source,
      'startsAt': instance.startsAt.toIso8601String(),
      'currentPeriodEnd': instance.currentPeriodEnd?.toIso8601String(),
    };
