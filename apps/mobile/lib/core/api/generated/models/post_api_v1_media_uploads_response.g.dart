// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_media_uploads_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MediaUploadsResponse _$PostApiV1MediaUploadsResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MediaUploadsResponse(
  data: UploadTicketDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MediaUploadsResponseToJson(
  PostApiV1MediaUploadsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
