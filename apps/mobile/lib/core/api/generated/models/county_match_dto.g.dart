// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'county_match_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CountyMatchDto _$CountyMatchDtoFromJson(Map<String, dynamic> json) =>
    CountyMatchDto(
      county: json['county'] == null
          ? null
          : CountyDto.fromJson(json['county'] as Map<String, dynamic>),
      countryId: json['countryId'] as String?,
    );

Map<String, dynamic> _$CountyMatchDtoToJson(CountyMatchDto instance) =>
    <String, dynamic>{
      'county': instance.county,
      'countryId': instance.countryId,
    };
