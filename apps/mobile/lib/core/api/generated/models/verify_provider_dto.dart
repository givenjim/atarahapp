// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'verify_provider_dto_status.dart';

part 'verify_provider_dto.g.dart';

@JsonSerializable()
class VerifyProviderDto {
  const VerifyProviderDto({
    required this.status,
    this.reason,
  });
  
  factory VerifyProviderDto.fromJson(Map<String, Object?> json) => _$VerifyProviderDtoFromJson(json);
  
  final VerifyProviderDtoStatus status;
  final String? reason;

  Map<String, Object?> toJson() => _$VerifyProviderDtoToJson(this);
}
