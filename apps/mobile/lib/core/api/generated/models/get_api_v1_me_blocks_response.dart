// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'blocked_member_dto.dart';

part 'get_api_v1_me_blocks_response.g.dart';

@JsonSerializable()
class GetApiV1MeBlocksResponse {
  const GetApiV1MeBlocksResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1MeBlocksResponse.fromJson(Map<String, Object?> json) => _$GetApiV1MeBlocksResponseFromJson(json);
  
  final List<BlockedMemberDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeBlocksResponseToJson(this);
}
