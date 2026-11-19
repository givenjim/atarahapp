// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'publish_service_dto.g.dart';

@JsonSerializable()
class PublishServiceDto {
  const PublishServiceDto({
    required this.categoryId,
    this.acceptTerms,
    this.termsVersion,
  });
  
  factory PublishServiceDto.fromJson(Map<String, Object?> json) => _$PublishServiceDtoFromJson(json);
  
  /// The marketplace category for the new draft.
  final String categoryId;
  final bool? acceptTerms;
  final String? termsVersion;

  Map<String, Object?> toJson() => _$PublishServiceDtoToJson(this);
}
