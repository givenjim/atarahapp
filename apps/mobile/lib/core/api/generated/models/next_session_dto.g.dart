// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'next_session_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NextSessionDto _$NextSessionDtoFromJson(Map<String, dynamic> json) =>
    NextSessionDto(
      bookingId: json['bookingId'] as String,
      mentorName: json['mentorName'] as String,
      sessionName: json['sessionName'] as String,
      startsAt: DateTime.parse(json['startsAt'] as String),
    );

Map<String, dynamic> _$NextSessionDtoToJson(NextSessionDto instance) =>
    <String, dynamic>{
      'bookingId': instance.bookingId,
      'mentorName': instance.mentorName,
      'sessionName': instance.sessionName,
      'startsAt': instance.startsAt.toIso8601String(),
    };
