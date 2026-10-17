// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'membership_summary_dto_plan.dart';

part 'membership_summary_dto.g.dart';

@JsonSerializable()
class MembershipSummaryDto {
  const MembershipSummaryDto({
    required this.plan,
    this.status,
    this.currentPeriodEnd,
  });

  factory MembershipSummaryDto.fromJson(Map<String, Object?> json) =>
      _$MembershipSummaryDtoFromJson(json);

  final MembershipSummaryDtoPlan plan;
  final String? status;
  final DateTime? currentPeriodEnd;

  Map<String, Object?> toJson() => _$MembershipSummaryDtoToJson(this);
}
