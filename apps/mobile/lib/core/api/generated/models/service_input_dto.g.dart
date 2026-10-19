// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_input_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceInputDto _$ServiceInputDtoFromJson(Map<String, dynamic> json) =>
    ServiceInputDto(
      title: json['title'] as String,
      priceType: ServiceInputDtoPriceType.fromJson(json['priceType'] as String),
      description: json['description'] as String?,
      priceMin: json['priceMin'] as num?,
      priceMax: json['priceMax'] as num?,
    );

Map<String, dynamic> _$ServiceInputDtoToJson(ServiceInputDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'priceType': instance.priceType,
      'priceMin': instance.priceMin,
      'priceMax': instance.priceMax,
    };
