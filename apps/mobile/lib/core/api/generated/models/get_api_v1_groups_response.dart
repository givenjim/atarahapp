// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'group_card_dto.dart';

part 'get_api_v1_groups_response.g.dart';

@JsonSerializable()
class GetApiV1GroupsResponse {
  const GetApiV1GroupsResponse({required this.data, this.meta});

  factory GetApiV1GroupsResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1GroupsResponseFromJson(json);

  final List<GroupCardDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1GroupsResponseToJson(this);
}
