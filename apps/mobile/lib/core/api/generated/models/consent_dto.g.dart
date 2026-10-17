// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consent_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConsentDto _$ConsentDtoFromJson(Map<String, dynamic> json) =>
    ConsentDto(terms: json['terms'] as bool, privacy: json['privacy'] as bool);

Map<String, dynamic> _$ConsentDtoToJson(ConsentDto instance) =>
    <String, dynamic>{'terms': instance.terms, 'privacy': instance.privacy};
