// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'credential_dto.g.dart';

@JsonSerializable()
class CredentialDto {
  const CredentialDto({
    required this.title,
    this.issuer,
    this.year,
  });
  
  factory CredentialDto.fromJson(Map<String, Object?> json) => _$CredentialDtoFromJson(json);
  
  final String title;
  final String? issuer;
  final num? year;

  Map<String, Object?> toJson() => _$CredentialDtoToJson(this);
}
