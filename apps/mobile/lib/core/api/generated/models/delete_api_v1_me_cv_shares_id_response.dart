// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cv_share_dto.dart';

part 'delete_api_v1_me_cv_shares_id_response.g.dart';

@JsonSerializable()
class DeleteApiV1MeCvSharesIdResponse {
  const DeleteApiV1MeCvSharesIdResponse({required this.data, this.meta});

  factory DeleteApiV1MeCvSharesIdResponse.fromJson(Map<String, Object?> json) =>
      _$DeleteApiV1MeCvSharesIdResponseFromJson(json);

  final CvShareDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$DeleteApiV1MeCvSharesIdResponseToJson(this);
}
