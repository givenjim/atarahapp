// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_terms_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SellerTermsDto _$SellerTermsDtoFromJson(Map<String, dynamic> json) =>
    SellerTermsDto(
      version: json['version'] as String,
      isDraft: json['isDraft'] as bool,
      title: json['title'] as String,
      body: json['body'] as String,
    );

Map<String, dynamic> _$SellerTermsDtoToJson(SellerTermsDto instance) =>
    <String, dynamic>{
      'version': instance.version,
      'isDraft': instance.isDraft,
      'title': instance.title,
      'body': instance.body,
    };
