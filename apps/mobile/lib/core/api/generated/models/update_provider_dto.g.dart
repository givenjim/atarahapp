// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_provider_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateProviderDto _$UpdateProviderDtoFromJson(Map<String, dynamic> json) =>
    UpdateProviderDto(
      name: json['name'] as String,
      type: OpportunityProviderType.fromJson(json['type'] as String),
      website: json['website'] as String?,
      ownerUserId: json['ownerUserId'] as String?,
    );

Map<String, dynamic> _$UpdateProviderDtoToJson(UpdateProviderDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'website': instance.website,
      'ownerUserId': instance.ownerUserId,
    };
