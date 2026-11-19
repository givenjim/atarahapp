// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmitResultDto _$SubmitResultDtoFromJson(Map<String, dynamic> json) =>
    SubmitResultDto(
      listing: ListingDto.fromJson(json['listing'] as Map<String, dynamic>),
      published: json['published'] as bool,
    );

Map<String, dynamic> _$SubmitResultDtoToJson(SubmitResultDto instance) =>
    <String, dynamic>{
      'listing': instance.listing,
      'published': instance.published,
    };
