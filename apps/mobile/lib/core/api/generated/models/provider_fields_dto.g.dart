// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_fields_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProviderFieldsDto _$ProviderFieldsDtoFromJson(Map<String, dynamic> json) =>
    ProviderFieldsDto(
      name: json['name'] as String,
      type: json['type'] == null
          ? null
          : OpportunityProviderType.fromJson(json['type'] as String),
      website: json['website'] as String?,
      ownerUserId: json['ownerUserId'] as String?,
    );

Map<String, dynamic> _$ProviderFieldsDtoToJson(ProviderFieldsDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'website': instance.website,
      'ownerUserId': instance.ownerUserId,
    };
