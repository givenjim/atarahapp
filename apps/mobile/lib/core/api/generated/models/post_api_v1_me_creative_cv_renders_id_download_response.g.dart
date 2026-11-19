// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_creative_cv_renders_id_download_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeCreativeCvRendersIdDownloadResponse
_$PostApiV1MeCreativeCvRendersIdDownloadResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MeCreativeCvRendersIdDownloadResponse(
  data: CvDownloadDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MeCreativeCvRendersIdDownloadResponseToJson(
  PostApiV1MeCreativeCvRendersIdDownloadResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
