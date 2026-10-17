// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'consent_dto.g.dart';

@JsonSerializable()
class ConsentDto {
  const ConsentDto({required this.terms, required this.privacy});

  factory ConsentDto.fromJson(Map<String, Object?> json) =>
      _$ConsentDtoFromJson(json);

  /// Terms of Service accepted. Must be true.
  final bool terms;

  /// Privacy Policy accepted. Must be true.
  final bool privacy;

  Map<String, Object?> toJson() => _$ConsentDtoToJson(this);
}
