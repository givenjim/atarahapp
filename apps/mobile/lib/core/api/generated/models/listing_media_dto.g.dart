// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_media_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListingMediaDto _$ListingMediaDtoFromJson(Map<String, dynamic> json) =>
    ListingMediaDto(
      id: json['id'] as String,
      kind: ListingMediaDtoKind.fromJson(json['kind'] as String),
      url: json['url'] as String?,
    );

Map<String, dynamic> _$ListingMediaDtoToJson(ListingMediaDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': instance.kind,
      'url': instance.url,
    };
