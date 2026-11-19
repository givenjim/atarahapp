// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'complete_refund_dto.g.dart';

@JsonSerializable()
class CompleteRefundDto {
  const CompleteRefundDto({
    this.providerReference,
  });
  
  factory CompleteRefundDto.fromJson(Map<String, Object?> json) => _$CompleteRefundDtoFromJson(json);
  
  /// Reference of the manual payout (M-Pesa receipt or bank reference).
  final String? providerReference;

  Map<String, Object?> toJson() => _$CompleteRefundDtoToJson(this);
}
