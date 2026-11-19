// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_cv_renders_id_download_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeCvRendersIdDownloadResponse
_$PostApiV1MeCvRendersIdDownloadResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1MeCvRendersIdDownloadResponse(
      data: CvDownloadDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1MeCvRendersIdDownloadResponseToJson(
  PostApiV1MeCvRendersIdDownloadResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
