// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_enquiry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateEnquiryDto _$CreateEnquiryDtoFromJson(Map<String, dynamic> json) =>
    CreateEnquiryDto(
      message: json['message'] as String,
      budget: json['budget'] as num?,
      preferredTiming: json['preferredTiming'] as String?,
    );

Map<String, dynamic> _$CreateEnquiryDtoToJson(CreateEnquiryDto instance) =>
    <String, dynamic>{
      'message': instance.message,
      'budget': instance.budget,
      'preferredTiming': instance.preferredTiming,
    };
