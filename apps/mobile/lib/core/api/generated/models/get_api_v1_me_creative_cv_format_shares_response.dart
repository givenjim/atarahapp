// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cv_share_dto.dart';

part 'get_api_v1_me_creative_cv_format_shares_response.g.dart';

@JsonSerializable()
class GetApiV1MeCreativeCvFormatSharesResponse {
  const GetApiV1MeCreativeCvFormatSharesResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1MeCreativeCvFormatSharesResponse.fromJson(Map<String, Object?> json) => _$GetApiV1MeCreativeCvFormatSharesResponseFromJson(json);
  
  final List<CvShareDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeCreativeCvFormatSharesResponseToJson(this);
}
