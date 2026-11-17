// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'marked_read_dto.dart';

part 'post_api_v1_notifications_read_all_response.g.dart';

@JsonSerializable()
class PostApiV1NotificationsReadAllResponse {
  const PostApiV1NotificationsReadAllResponse({required this.data, this.meta});

  factory PostApiV1NotificationsReadAllResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1NotificationsReadAllResponseFromJson(json);

  final MarkedReadDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1NotificationsReadAllResponseToJson(this);
}
