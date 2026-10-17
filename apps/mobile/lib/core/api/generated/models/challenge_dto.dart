// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'challenge_dto.g.dart';

@JsonSerializable()
class ChallengeDto {
  const ChallengeDto({required this.challengeToken});

  factory ChallengeDto.fromJson(Map<String, Object?> json) =>
      _$ChallengeDtoFromJson(json);

  /// Short-lived token returned by POST /admin/auth/login.
  final String challengeToken;

  Map<String, Object?> toJson() => _$ChallengeDtoToJson(this);
}
