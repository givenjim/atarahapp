// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'applicant_ref_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplicantRefDto _$ApplicantRefDtoFromJson(Map<String, dynamic> json) =>
    ApplicantRefDto(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      handle: json['handle'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$ApplicantRefDtoToJson(ApplicantRefDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'displayName': instance.displayName,
      'handle': instance.handle,
      'email': instance.email,
    };
