// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceDto _$ServiceDtoFromJson(Map<String, dynamic> json) => ServiceDto(
  id: json['id'] as String,
  title: json['title'] as String,
  priceType: ServiceDtoPriceType.fromJson(json['priceType'] as String),
  status: ServiceDtoStatus.fromJson(json['status'] as String),
  description: json['description'] as String?,
  priceMin: json['priceMin'] as num?,
  priceMax: json['priceMax'] as num?,
);

Map<String, dynamic> _$ServiceDtoToJson(ServiceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'priceType': instance.priceType,
      'priceMin': instance.priceMin,
      'priceMax': instance.priceMax,
      'status': instance.status,
    };
