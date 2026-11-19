// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'submit_result_dto.dart';

part 'post_api_v1_me_listings_id_submit_response.g.dart';

@JsonSerializable()
class PostApiV1MeListingsIdSubmitResponse {
  const PostApiV1MeListingsIdSubmitResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1MeListingsIdSubmitResponse.fromJson(Map<String, Object?> json) => _$PostApiV1MeListingsIdSubmitResponseFromJson(json);
  
  final SubmitResultDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1MeListingsIdSubmitResponseToJson(this);
}
