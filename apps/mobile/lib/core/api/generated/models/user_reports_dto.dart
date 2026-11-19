// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'user_report_dto.dart';

part 'user_reports_dto.g.dart';

@JsonSerializable()
class UserReportsDto {
  const UserReportsDto({
    required this.about,
    required this.made,
    required this.recent,
  });
  
  factory UserReportsDto.fromJson(Map<String, Object?> json) => _$UserReportsDtoFromJson(json);
  
  /// Cases about this member or their content (reporters are never shown).
  final num about;

  /// Reports this member has made.
  final num made;
  final List<UserReportDto> recent;

  Map<String, Object?> toJson() => _$UserReportsDtoToJson(this);
}
