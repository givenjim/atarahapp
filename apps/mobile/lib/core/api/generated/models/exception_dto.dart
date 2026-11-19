// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'exception_dto.g.dart';

@JsonSerializable()
class ExceptionDto {
  const ExceptionDto({
    required this.id,
    required this.date,
    this.reason,
  });
  
  factory ExceptionDto.fromJson(Map<String, Object?> json) => _$ExceptionDtoFromJson(json);
  
  final String id;
  final String date;
  final String? reason;

  Map<String, Object?> toJson() => _$ExceptionDtoToJson(this);
}
