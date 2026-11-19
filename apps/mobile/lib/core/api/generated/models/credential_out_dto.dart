// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'credential_out_dto.g.dart';

@JsonSerializable()
class CredentialOutDto {
  const CredentialOutDto({
    required this.title,
    this.issuer,
    this.year,
  });
  
  factory CredentialOutDto.fromJson(Map<String, Object?> json) => _$CredentialOutDtoFromJson(json);
  
  final String title;
  final String? issuer;
  final num? year;

  Map<String, Object?> toJson() => _$CredentialOutDtoToJson(this);
}
