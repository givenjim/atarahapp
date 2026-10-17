// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'preferences_dto.dart';

part 'put_api_v1_notifications_preferences_response.g.dart';

@JsonSerializable()
class PutApiV1NotificationsPreferencesResponse {
  const PutApiV1NotificationsPreferencesResponse({
    required this.data,
    this.meta,
  });

  factory PutApiV1NotificationsPreferencesResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PutApiV1NotificationsPreferencesResponseFromJson(json);

  final PreferencesDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PutApiV1NotificationsPreferencesResponseToJson(this);
}
