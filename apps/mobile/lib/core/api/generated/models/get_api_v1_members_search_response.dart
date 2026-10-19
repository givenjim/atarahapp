// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'member_hit_dto.dart';

part 'get_api_v1_members_search_response.g.dart';

@JsonSerializable()
class GetApiV1MembersSearchResponse {
  const GetApiV1MembersSearchResponse({required this.data, this.meta});

  factory GetApiV1MembersSearchResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1MembersSearchResponseFromJson(json);

  final List<MemberHitDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MembersSearchResponseToJson(this);
}
