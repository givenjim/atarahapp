// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'opportunity_provider_type.dart';

part 'update_provider_dto.g.dart';

@JsonSerializable()
class UpdateProviderDto {
  const UpdateProviderDto({
    required this.name,
    required this.type,
    required this.website,
    required this.ownerUserId,
  });
  
  factory UpdateProviderDto.fromJson(Map<String, Object?> json) => _$UpdateProviderDtoFromJson(json);
  
  final String name;
  final OpportunityProviderType type;
  final String? website;
  final String? ownerUserId;

  Map<String, Object?> toJson() => _$UpdateProviderDtoToJson(this);
}
