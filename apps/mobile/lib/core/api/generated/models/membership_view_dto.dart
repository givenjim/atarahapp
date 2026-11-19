// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'membership_view_dto_plan.dart';
import 'plan_row_dto.dart';

part 'membership_view_dto.g.dart';

@JsonSerializable()
class MembershipViewDto {
  const MembershipViewDto({
    required this.plan,
    required this.proPriceLabel,
    required this.comparison,
    required this.scholarshipNote,
    this.status,
    this.currentPeriodEnd,
  });
  
  factory MembershipViewDto.fromJson(Map<String, Object?> json) => _$MembershipViewDtoFromJson(json);
  
  final MembershipViewDtoPlan plan;
  final String? status;
  final DateTime? currentPeriodEnd;

  /// Pro monthly price, ready to show: "KES 1,200 a month".
  final String proPriceLabel;

  /// The Free versus Pro table.
  final List<PlanRowDto> comparison;

  /// The scholarship note shown under the table.
  final String scholarshipNote;

  Map<String, Object?> toJson() => _$MembershipViewDtoToJson(this);
}
