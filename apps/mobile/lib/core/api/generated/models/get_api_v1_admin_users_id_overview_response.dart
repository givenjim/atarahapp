// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_user_overview_dto.dart';

part 'get_api_v1_admin_users_id_overview_response.g.dart';

@JsonSerializable()
class GetApiV1AdminUsersIdOverviewResponse {
  const GetApiV1AdminUsersIdOverviewResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1AdminUsersIdOverviewResponse.fromJson(Map<String, Object?> json) => _$GetApiV1AdminUsersIdOverviewResponseFromJson(json);
  
  final AdminUserOverviewDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminUsersIdOverviewResponseToJson(this);
}
