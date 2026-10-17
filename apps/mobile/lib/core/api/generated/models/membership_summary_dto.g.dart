// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MembershipSummaryDto _$MembershipSummaryDtoFromJson(
  Map<String, dynamic> json,
) => MembershipSummaryDto(
  plan: MembershipSummaryDtoPlan.fromJson(json['plan'] as String),
  status: json['status'] as String?,
  currentPeriodEnd: json['currentPeriodEnd'] == null
      ? null
      : DateTime.parse(json['currentPeriodEnd'] as String),
);

Map<String, dynamic> _$MembershipSummaryDtoToJson(
  MembershipSummaryDto instance,
) => <String, dynamic>{
  'plan': instance.plan,
  'status': instance.status,
  'currentPeriodEnd': instance.currentPeriodEnd?.toIso8601String(),
};
