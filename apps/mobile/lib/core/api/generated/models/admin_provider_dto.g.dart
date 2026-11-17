// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_provider_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminProviderDto _$AdminProviderDtoFromJson(Map<String, dynamic> json) =>
    AdminProviderDto(
      id: json['id'] as String,
      name: json['name'] as String,
      type: OpportunityProviderType.fromJson(json['type'] as String),
      verificationStatus: VerificationStatus.fromJson(
        json['verificationStatus'] as String,
      ),
      opportunitiesCount: json['opportunitiesCount'] as num,
      createdAt: DateTime.parse(json['createdAt'] as String),
      website: json['website'] as String?,
      ownerUserId: json['ownerUserId'] as String?,
    );

Map<String, dynamic> _$AdminProviderDtoToJson(AdminProviderDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'website': instance.website,
      'verificationStatus': instance.verificationStatus,
      'ownerUserId': instance.ownerUserId,
      'opportunitiesCount': instance.opportunitiesCount,
      'createdAt': instance.createdAt.toIso8601String(),
    };
