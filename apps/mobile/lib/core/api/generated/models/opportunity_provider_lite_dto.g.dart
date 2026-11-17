// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opportunity_provider_lite_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpportunityProviderLiteDto _$OpportunityProviderLiteDtoFromJson(
  Map<String, dynamic> json,
) => OpportunityProviderLiteDto(
  id: json['id'] as String,
  name: json['name'] as String,
  type: OpportunityProviderType.fromJson(json['type'] as String),
  verified: json['verified'] as bool,
  logoUrl: json['logoUrl'] as String?,
  website: json['website'] as String?,
);

Map<String, dynamic> _$OpportunityProviderLiteDtoToJson(
  OpportunityProviderLiteDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'verified': instance.verified,
  'logoUrl': instance.logoUrl,
  'website': instance.website,
};
