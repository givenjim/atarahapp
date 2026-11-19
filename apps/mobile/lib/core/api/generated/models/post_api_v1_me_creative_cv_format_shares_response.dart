// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cv_share_created_dto.dart';

part 'post_api_v1_me_creative_cv_format_shares_response.g.dart';

@JsonSerializable()
class PostApiV1MeCreativeCvFormatSharesResponse {
  const PostApiV1MeCreativeCvFormatSharesResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1MeCreativeCvFormatSharesResponse.fromJson(Map<String, Object?> json) => _$PostApiV1MeCreativeCvFormatSharesResponseFromJson(json);
  
  final CvShareCreatedDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1MeCreativeCvFormatSharesResponseToJson(this);
}
