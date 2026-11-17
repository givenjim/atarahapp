// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_two_step_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeTwoStepResponse _$GetApiV1MeTwoStepResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeTwoStepResponse(
  data: TwoStepDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeTwoStepResponseToJson(
  GetApiV1MeTwoStepResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
