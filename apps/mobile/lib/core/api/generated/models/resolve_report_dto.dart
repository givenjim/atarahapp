// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'resolve_report_dto_action.dart';

part 'resolve_report_dto.g.dart';

@JsonSerializable()
class ResolveReportDto {
  const ResolveReportDto({
    required this.action,
    required this.note,
  });
  
  factory ResolveReportDto.fromJson(Map<String, Object?> json) => _$ResolveReportDtoFromJson(json);
  
  final ResolveReportDtoAction action;
  final String note;

  Map<String, Object?> toJson() => _$ResolveReportDtoToJson(this);
}
