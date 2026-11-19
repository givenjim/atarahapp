// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exception_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExceptionDto _$ExceptionDtoFromJson(Map<String, dynamic> json) => ExceptionDto(
  id: json['id'] as String,
  date: json['date'] as String,
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$ExceptionDtoToJson(ExceptionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'reason': instance.reason,
    };
