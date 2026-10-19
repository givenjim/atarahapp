// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'own_contact_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OwnContactDto _$OwnContactDtoFromJson(Map<String, dynamic> json) =>
    OwnContactDto(
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      showEmail: json['showEmail'] as bool,
      showPhone: json['showPhone'] as bool,
      forConnections: json['forConnections'] as bool,
    );

Map<String, dynamic> _$OwnContactDtoToJson(OwnContactDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'phone': instance.phone,
      'showEmail': instance.showEmail,
      'showPhone': instance.showPhone,
      'forConnections': instance.forConnections,
    };
