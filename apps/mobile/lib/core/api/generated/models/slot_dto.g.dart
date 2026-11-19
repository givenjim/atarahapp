// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slot_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SlotDto _$SlotDtoFromJson(Map<String, dynamic> json) => SlotDto(
  startsAt: DateTime.parse(json['startsAt'] as String),
  endsAt: DateTime.parse(json['endsAt'] as String),
  localDate: json['localDate'] as String,
);

Map<String, dynamic> _$SlotDtoToJson(SlotDto instance) => <String, dynamic>{
  'startsAt': instance.startsAt.toIso8601String(),
  'endsAt': instance.endsAt.toIso8601String(),
  'localDate': instance.localDate,
};
