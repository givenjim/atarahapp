// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_asset_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaAssetDto _$MediaAssetDtoFromJson(Map<String, dynamic> json) =>
    MediaAssetDto(
      id: json['id'] as String,
      kind: MediaAssetDtoKind.fromJson(json['kind'] as String),
      bucket: MediaAssetDtoBucket.fromJson(json['bucket'] as String),
      status: MediaAssetDtoStatus.fromJson(json['status'] as String),
      mimeType: json['mimeType'] as String,
      sizeBytes: json['sizeBytes'] as num,
      createdAt: DateTime.parse(json['createdAt'] as String),
      width: json['width'] as num?,
      height: json['height'] as num?,
      rejectionReason: json['rejectionReason'] as String?,
      url: json['url'] as String?,
      variants: (json['variants'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$MediaAssetDtoToJson(MediaAssetDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': instance.kind,
      'bucket': instance.bucket,
      'status': instance.status,
      'mimeType': instance.mimeType,
      'sizeBytes': instance.sizeBytes,
      'width': instance.width,
      'height': instance.height,
      'rejectionReason': instance.rejectionReason,
      'url': instance.url,
      'variants': instance.variants,
      'createdAt': instance.createdAt.toIso8601String(),
    };
