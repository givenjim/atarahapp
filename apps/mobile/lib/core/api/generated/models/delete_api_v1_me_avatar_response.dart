// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'onboarding_state_dto.dart';

part 'delete_api_v1_me_avatar_response.g.dart';

@JsonSerializable()
class DeleteApiV1MeAvatarResponse {
  const DeleteApiV1MeAvatarResponse({required this.data, this.meta});

  factory DeleteApiV1MeAvatarResponse.fromJson(Map<String, Object?> json) =>
      _$DeleteApiV1MeAvatarResponseFromJson(json);

  final OnboardingStateDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$DeleteApiV1MeAvatarResponseToJson(this);
}
