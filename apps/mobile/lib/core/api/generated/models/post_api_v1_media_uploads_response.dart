// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'upload_ticket_dto.dart';

part 'post_api_v1_media_uploads_response.g.dart';

@JsonSerializable()
class PostApiV1MediaUploadsResponse {
  const PostApiV1MediaUploadsResponse({required this.data, this.meta});

  factory PostApiV1MediaUploadsResponse.fromJson(Map<String, Object?> json) =>
      _$PostApiV1MediaUploadsResponseFromJson(json);

  final UploadTicketDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1MediaUploadsResponseToJson(this);
}
