// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_service_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateServiceDto _$UpdateServiceDtoFromJson(Map<String, dynamic> json) =>
    UpdateServiceDto(
      title: json['title'] as String?,
      description: json['description'] as String?,
      priceType: json['priceType'] == null
          ? null
          : UpdateServiceDtoPriceType.fromJson(json['priceType'] as String),
      priceMin: json['priceMin'] as num?,
      priceMax: json['priceMax'] as num?,
    );

Map<String, dynamic> _$UpdateServiceDtoToJson(UpdateServiceDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'priceType': instance.priceType,
      'priceMin': instance.priceMin,
      'priceMax': instance.priceMax,
    };
