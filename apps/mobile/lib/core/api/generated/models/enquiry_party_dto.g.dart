// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enquiry_party_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnquiryPartyDto _$EnquiryPartyDtoFromJson(Map<String, dynamic> json) =>
    EnquiryPartyDto(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      handle: json['handle'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$EnquiryPartyDtoToJson(EnquiryPartyDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'displayName': instance.displayName,
      'handle': instance.handle,
      'avatarUrl': instance.avatarUrl,
    };
