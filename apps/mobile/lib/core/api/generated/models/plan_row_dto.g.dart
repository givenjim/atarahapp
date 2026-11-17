// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_row_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanRowDto _$PlanRowDtoFromJson(Map<String, dynamic> json) => PlanRowDto(
  label: json['label'] as String,
  free: json['free'] as bool,
  pro: json['pro'] as bool,
);

Map<String, dynamic> _$PlanRowDtoToJson(PlanRowDto instance) =>
    <String, dynamic>{
      'label': instance.label,
      'free': instance.free,
      'pro': instance.pro,
    };
