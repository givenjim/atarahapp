// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_view_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MembershipViewDto _$MembershipViewDtoFromJson(Map<String, dynamic> json) =>
    MembershipViewDto(
      plan: MembershipViewDtoPlan.fromJson(json['plan'] as String),
      proPriceLabel: json['proPriceLabel'] as String,
      comparison: (json['comparison'] as List<dynamic>)
          .map((e) => PlanRowDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      scholarshipNote: json['scholarshipNote'] as String,
      status: json['status'] as String?,
      currentPeriodEnd: json['currentPeriodEnd'] == null
          ? null
          : DateTime.parse(json['currentPeriodEnd'] as String),
    );

Map<String, dynamic> _$MembershipViewDtoToJson(MembershipViewDto instance) =>
    <String, dynamic>{
      'plan': instance.plan,
      'status': instance.status,
      'currentPeriodEnd': instance.currentPeriodEnd?.toIso8601String(),
      'proPriceLabel': instance.proPriceLabel,
      'comparison': instance.comparison,
      'scholarshipNote': instance.scholarshipNote,
    };
