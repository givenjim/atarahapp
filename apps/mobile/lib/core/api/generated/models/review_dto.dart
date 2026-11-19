// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'review_dto.g.dart';

@JsonSerializable()
class ReviewDto {
  const ReviewDto({
    required this.rating,
    this.body,
  });
  
  factory ReviewDto.fromJson(Map<String, Object?> json) => _$ReviewDtoFromJson(json);
  
  final num rating;
  final String? body;

  Map<String, Object?> toJson() => _$ReviewDtoToJson(this);
}
