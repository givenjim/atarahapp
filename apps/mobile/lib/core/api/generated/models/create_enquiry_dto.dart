// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'create_enquiry_dto.g.dart';

@JsonSerializable()
class CreateEnquiryDto {
  const CreateEnquiryDto({
    required this.message,
    this.budget,
    this.preferredTiming,
  });
  
  factory CreateEnquiryDto.fromJson(Map<String, Object?> json) => _$CreateEnquiryDtoFromJson(json);
  
  /// What you need.
  final String message;

  /// Whole shillings.
  final num? budget;

  /// For example "Next month" or "By 15 December".
  final String? preferredTiming;

  Map<String, Object?> toJson() => _$CreateEnquiryDtoToJson(this);
}
