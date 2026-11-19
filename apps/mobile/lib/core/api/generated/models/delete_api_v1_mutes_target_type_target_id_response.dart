// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'mute_state_dto.dart';

part 'delete_api_v1_mutes_target_type_target_id_response.g.dart';

@JsonSerializable()
class DeleteApiV1MutesTargetTypeTargetIdResponse {
  const DeleteApiV1MutesTargetTypeTargetIdResponse({
    required this.data,
    this.meta,
  });
  
  factory DeleteApiV1MutesTargetTypeTargetIdResponse.fromJson(Map<String, Object?> json) => _$DeleteApiV1MutesTargetTypeTargetIdResponseFromJson(json);
  
  final MuteStateDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$DeleteApiV1MutesTargetTypeTargetIdResponseToJson(this);
}
