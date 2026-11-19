// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'add_exception_dto.g.dart';

@JsonSerializable()
class AddExceptionDto {
  const AddExceptionDto({
    required this.date,
    this.reason,
  });
  
  factory AddExceptionDto.fromJson(Map<String, Object?> json) => _$AddExceptionDtoFromJson(json);
  
  /// A local calendar date.
  final String date;
  final String? reason;

  Map<String, Object?> toJson() => _$AddExceptionDtoToJson(this);
}
