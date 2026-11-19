// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingRequestDto _$BookingRequestDtoFromJson(Map<String, dynamic> json) =>
    BookingRequestDto(
      id: json['id'] as String,
      menteeName: json['menteeName'] as String,
      sessionName: json['sessionName'] as String,
      startsAt: DateTime.parse(json['startsAt'] as String),
      endsAt: DateTime.parse(json['endsAt'] as String),
      status: json['status'] as String,
    );

Map<String, dynamic> _$BookingRequestDtoToJson(BookingRequestDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'menteeName': instance.menteeName,
      'sessionName': instance.sessionName,
      'startsAt': instance.startsAt.toIso8601String(),
      'endsAt': instance.endsAt.toIso8601String(),
      'status': instance.status,
    };
