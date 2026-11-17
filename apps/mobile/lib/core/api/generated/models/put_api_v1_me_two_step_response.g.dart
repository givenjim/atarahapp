// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_api_v1_me_two_step_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutApiV1MeTwoStepResponse _$PutApiV1MeTwoStepResponseFromJson(
  Map<String, dynamic> json,
) => PutApiV1MeTwoStepResponse(
  data: TwoStepDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PutApiV1MeTwoStepResponseToJson(
  PutApiV1MeTwoStepResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
