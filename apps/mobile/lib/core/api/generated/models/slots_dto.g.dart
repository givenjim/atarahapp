// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slots_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SlotsDto _$SlotsDtoFromJson(Map<String, dynamic> json) => SlotsDto(
  mentorId: json['mentorId'] as String,
  sessionTypeId: json['sessionTypeId'] as String,
  durationMinutes: json['durationMinutes'] as num,
  mentorTimeZone: json['mentorTimeZone'] as String,
  viewerTimeZone: json['viewerTimeZone'] as String,
  slots: (json['slots'] as List<dynamic>)
      .map((e) => SlotDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SlotsDtoToJson(SlotsDto instance) => <String, dynamic>{
  'mentorId': instance.mentorId,
  'sessionTypeId': instance.sessionTypeId,
  'durationMinutes': instance.durationMinutes,
  'mentorTimeZone': instance.mentorTimeZone,
  'viewerTimeZone': instance.viewerTimeZone,
  'slots': instance.slots,
};
