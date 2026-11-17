// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'unread_dto.dart';

part 'post_api_v1_notifications_id_read_response.g.dart';

@JsonSerializable()
class PostApiV1NotificationsIdReadResponse {
  const PostApiV1NotificationsIdReadResponse({required this.data, this.meta});

  factory PostApiV1NotificationsIdReadResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1NotificationsIdReadResponseFromJson(json);

  final UnreadDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1NotificationsIdReadResponseToJson(this);
}
