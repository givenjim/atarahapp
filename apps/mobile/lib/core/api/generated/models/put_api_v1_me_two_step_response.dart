// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'two_step_dto.dart';

part 'put_api_v1_me_two_step_response.g.dart';

@JsonSerializable()
class PutApiV1MeTwoStepResponse {
  const PutApiV1MeTwoStepResponse({
    required this.data,
    this.meta,
  });
  
  factory PutApiV1MeTwoStepResponse.fromJson(Map<String, Object?> json) => _$PutApiV1MeTwoStepResponseFromJson(json);
  
  final TwoStepDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PutApiV1MeTwoStepResponseToJson(this);
}
