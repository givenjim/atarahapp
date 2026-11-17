// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'user_membership_dto.g.dart';

@JsonSerializable()
class UserMembershipDto {
  const UserMembershipDto({
    required this.plan,
    required this.status,
    required this.source,
    required this.startsAt,
    this.currentPeriodEnd,
  });

  factory UserMembershipDto.fromJson(Map<String, Object?> json) =>
      _$UserMembershipDtoFromJson(json);

  final String plan;
  final String status;
  final String source;
  final DateTime startsAt;
  final DateTime? currentPeriodEnd;

  Map<String, Object?> toJson() => _$UserMembershipDtoToJson(this);
}
