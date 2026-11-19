// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publish_service_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublishServiceDto _$PublishServiceDtoFromJson(Map<String, dynamic> json) =>
    PublishServiceDto(
      categoryId: json['categoryId'] as String,
      acceptTerms: json['acceptTerms'] as bool?,
      termsVersion: json['termsVersion'] as String?,
    );

Map<String, dynamic> _$PublishServiceDtoToJson(PublishServiceDto instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'acceptTerms': instance.acceptTerms,
      'termsVersion': instance.termsVersion,
    };
