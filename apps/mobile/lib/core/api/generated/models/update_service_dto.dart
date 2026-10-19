// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'update_service_dto_price_type.dart';

part 'update_service_dto.g.dart';

@JsonSerializable()
class UpdateServiceDto {
  const UpdateServiceDto({
    this.title,
    this.description,
    this.priceType,
    this.priceMin,
    this.priceMax,
  });

  factory UpdateServiceDto.fromJson(Map<String, Object?> json) =>
      _$UpdateServiceDtoFromJson(json);

  final String? title;

  /// Empty clears it.
  final String? description;
  final UpdateServiceDtoPriceType? priceType;
  final num? priceMin;
  final num? priceMax;

  Map<String, Object?> toJson() => _$UpdateServiceDtoToJson(this);
}
