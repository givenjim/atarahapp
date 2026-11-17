// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_api_v1_mutes_target_type_target_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteApiV1MutesTargetTypeTargetIdResponse
_$DeleteApiV1MutesTargetTypeTargetIdResponseFromJson(
  Map<String, dynamic> json,
) => DeleteApiV1MutesTargetTypeTargetIdResponse(
  data: MuteStateDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$DeleteApiV1MutesTargetTypeTargetIdResponseToJson(
  DeleteApiV1MutesTargetTypeTargetIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
