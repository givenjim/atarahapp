// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'service_dto.dart';

part 'post_api_v1_me_services_response.g.dart';

@JsonSerializable()
class PostApiV1MeServicesResponse {
  const PostApiV1MeServicesResponse({required this.data, this.meta});

  factory PostApiV1MeServicesResponse.fromJson(Map<String, Object?> json) =>
      _$PostApiV1MeServicesResponseFromJson(json);

  final ServiceDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1MeServicesResponseToJson(this);
}
