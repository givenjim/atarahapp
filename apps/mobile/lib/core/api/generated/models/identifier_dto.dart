// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'identifier_dto.g.dart';

@JsonSerializable()
class IdentifierDto {
  const IdentifierDto({required this.identifier});

  factory IdentifierDto.fromJson(Map<String, Object?> json) =>
      _$IdentifierDtoFromJson(json);

  /// Email address or phone number (Kenyan local formats are accepted).
  final String identifier;

  Map<String, Object?> toJson() => _$IdentifierDtoToJson(this);
}
