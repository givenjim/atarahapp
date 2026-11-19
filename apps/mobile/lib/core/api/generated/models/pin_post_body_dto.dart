// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'pin_post_body_dto.g.dart';

@JsonSerializable()
class PinPostBodyDto {
  const PinPostBodyDto({
    required this.postId,
  });
  
  factory PinPostBodyDto.fromJson(Map<String, Object?> json) => _$PinPostBodyDtoFromJson(json);
  
  /// A post in this group.
  final String postId;

  Map<String, Object?> toJson() => _$PinPostBodyDtoToJson(this);
}
