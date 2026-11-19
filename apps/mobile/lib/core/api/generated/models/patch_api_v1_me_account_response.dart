// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'account_dto.dart';

part 'patch_api_v1_me_account_response.g.dart';

@JsonSerializable()
class PatchApiV1MeAccountResponse {
  const PatchApiV1MeAccountResponse({
    required this.data,
    this.meta,
  });
  
  factory PatchApiV1MeAccountResponse.fromJson(Map<String, Object?> json) => _$PatchApiV1MeAccountResponseFromJson(json);
  
  final AccountDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PatchApiV1MeAccountResponseToJson(this);
}
