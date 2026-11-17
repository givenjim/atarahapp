// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'opportunity_provider_type.dart';

part 'provider_fields_dto.g.dart';

@JsonSerializable()
class ProviderFieldsDto {
  const ProviderFieldsDto({
    required this.name,
    this.type,
    this.website,
    this.ownerUserId,
  });

  factory ProviderFieldsDto.fromJson(Map<String, Object?> json) =>
      _$ProviderFieldsDtoFromJson(json);

  final String name;
  final OpportunityProviderType? type;
  final String? website;

  /// The provider account that may submit listings.
  final String? ownerUserId;

  Map<String, Object?> toJson() => _$ProviderFieldsDtoToJson(this);
}
