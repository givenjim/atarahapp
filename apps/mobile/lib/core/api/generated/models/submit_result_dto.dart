// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'listing_dto.dart';

part 'submit_result_dto.g.dart';

@JsonSerializable()
class SubmitResultDto {
  const SubmitResultDto({
    required this.listing,
    required this.published,
  });
  
  factory SubmitResultDto.fromJson(Map<String, Object?> json) => _$SubmitResultDtoFromJson(json);
  
  final ListingDto listing;

  /// True when it went live straight away; false when it is waiting for review.
  final bool published;

  Map<String, Object?> toJson() => _$SubmitResultDtoToJson(this);
}
