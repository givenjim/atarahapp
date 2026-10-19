// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_media_uploads_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminMediaUploadsResponse _$PostApiV1AdminMediaUploadsResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminMediaUploadsResponse(
  data: UploadTicketDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminMediaUploadsResponseToJson(
  PostApiV1AdminMediaUploadsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
