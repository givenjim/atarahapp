// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'membership_view_dto.dart';

part 'get_api_v1_me_membership_response.g.dart';

@JsonSerializable()
class GetApiV1MeMembershipResponse {
  const GetApiV1MeMembershipResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1MeMembershipResponse.fromJson(Map<String, Object?> json) => _$GetApiV1MeMembershipResponseFromJson(json);
  
  final MembershipViewDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeMembershipResponseToJson(this);
}
