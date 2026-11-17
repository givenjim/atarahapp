// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'opportunity_provider_type.dart';
import 'verification_status.dart';

part 'admin_provider_dto.g.dart';

@JsonSerializable()
class AdminProviderDto {
  const AdminProviderDto({
    required this.id,
    required this.name,
    required this.type,
    required this.verificationStatus,
    required this.opportunitiesCount,
    required this.createdAt,
    this.website,
    this.ownerUserId,
  });

  factory AdminProviderDto.fromJson(Map<String, Object?> json) =>
      _$AdminProviderDtoFromJson(json);

  final String id;
  final String name;
  final OpportunityProviderType type;
  final String? website;
  final VerificationStatus verificationStatus;
  final String? ownerUserId;
  final num opportunitiesCount;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$AdminProviderDtoToJson(this);
}
