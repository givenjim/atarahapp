// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'opportunity_provider_type.dart';

part 'opportunity_provider_lite_dto.g.dart';

@JsonSerializable()
class OpportunityProviderLiteDto {
  const OpportunityProviderLiteDto({
    required this.id,
    required this.name,
    required this.type,
    required this.verified,
    this.logoUrl,
    this.website,
  });
  
  factory OpportunityProviderLiteDto.fromJson(Map<String, Object?> json) => _$OpportunityProviderLiteDtoFromJson(json);
  
  final String id;
  final String name;
  final OpportunityProviderType type;
  final bool verified;
  final String? logoUrl;
  final String? website;

  Map<String, Object?> toJson() => _$OpportunityProviderLiteDtoToJson(this);
}
