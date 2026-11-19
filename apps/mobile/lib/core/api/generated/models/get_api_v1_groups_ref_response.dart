// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'group_detail_dto.dart';

part 'get_api_v1_groups_ref_response.g.dart';

@JsonSerializable()
class GetApiV1GroupsRefResponse {
  const GetApiV1GroupsRefResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1GroupsRefResponse.fromJson(Map<String, Object?> json) => _$GetApiV1GroupsRefResponseFromJson(json);
  
  final GroupDetailDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1GroupsRefResponseToJson(this);
}
