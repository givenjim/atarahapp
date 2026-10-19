// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'upload_ticket_dto.dart';

part 'post_api_v1_admin_media_uploads_response.g.dart';

@JsonSerializable()
class PostApiV1AdminMediaUploadsResponse {
  const PostApiV1AdminMediaUploadsResponse({required this.data, this.meta});

  factory PostApiV1AdminMediaUploadsResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminMediaUploadsResponseFromJson(json);

  final UploadTicketDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminMediaUploadsResponseToJson(this);
}
