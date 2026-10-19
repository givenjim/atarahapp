// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'service_dto_price_type.dart';
import 'service_dto_status.dart';

part 'service_dto.g.dart';

@JsonSerializable()
class ServiceDto {
  const ServiceDto({
    required this.id,
    required this.title,
    required this.priceType,
    required this.status,
    this.description,
    this.priceMin,
    this.priceMax,
  });

  factory ServiceDto.fromJson(Map<String, Object?> json) =>
      _$ServiceDtoFromJson(json);

  final String id;
  final String title;
  final String? description;
  final ServiceDtoPriceType priceType;

  /// Whole Kenya shillings.
  final num? priceMin;

  /// Whole Kenya shillings.
  final num? priceMax;
  final ServiceDtoStatus status;

  Map<String, Object?> toJson() => _$ServiceDtoToJson(this);
}
