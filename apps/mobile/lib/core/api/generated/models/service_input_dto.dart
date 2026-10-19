// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'service_input_dto_price_type.dart';

part 'service_input_dto.g.dart';

@JsonSerializable()
class ServiceInputDto {
  const ServiceInputDto({
    required this.title,
    required this.priceType,
    this.description,
    this.priceMin,
    this.priceMax,
  });

  factory ServiceInputDto.fromJson(Map<String, Object?> json) =>
      _$ServiceInputDtoFromJson(json);

  final String title;
  final String? description;
  final ServiceInputDtoPriceType priceType;

  /// Whole Kenya shillings. FIXED and RANGE only.
  final num? priceMin;

  /// Whole Kenya shillings. RANGE only, at least the minimum.
  final num? priceMax;

  Map<String, Object?> toJson() => _$ServiceInputDtoToJson(this);
}
