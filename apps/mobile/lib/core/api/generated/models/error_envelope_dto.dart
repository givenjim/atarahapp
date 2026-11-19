// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'error.dart';

part 'error_envelope_dto.g.dart';

@JsonSerializable()
class ErrorEnvelopeDto {
  const ErrorEnvelopeDto({
    required this.error,
  });
  
  factory ErrorEnvelopeDto.fromJson(Map<String, Object?> json) => _$ErrorEnvelopeDtoFromJson(json);
  
  final Error error;

  Map<String, Object?> toJson() => _$ErrorEnvelopeDtoToJson(this);
}
