// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'set_direct_publish_dto.g.dart';

@JsonSerializable()
class SetDirectPublishDto {
  const SetDirectPublishDto({
    required this.canPublishDirectly,
  });
  
  factory SetDirectPublishDto.fromJson(Map<String, Object?> json) => _$SetDirectPublishDtoFromJson(json);
  
  final bool canPublishDirectly;

  Map<String, Object?> toJson() => _$SetDirectPublishDtoToJson(this);
}
