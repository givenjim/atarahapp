// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cv_share_dto.dart';

part 'delete_api_v1_me_creative_cv_shares_id_response.g.dart';

@JsonSerializable()
class DeleteApiV1MeCreativeCvSharesIdResponse {
  const DeleteApiV1MeCreativeCvSharesIdResponse({
    required this.data,
    this.meta,
  });
  
  factory DeleteApiV1MeCreativeCvSharesIdResponse.fromJson(Map<String, Object?> json) => _$DeleteApiV1MeCreativeCvSharesIdResponseFromJson(json);
  
  final CvShareDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$DeleteApiV1MeCreativeCvSharesIdResponseToJson(this);
}
