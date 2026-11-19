// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'help_block_dto_type.dart';

part 'help_block_dto.g.dart';

@JsonSerializable()
class HelpBlockDto {
  const HelpBlockDto({
    required this.type,
    this.text,
    this.title,
    this.attribution,
  });
  
  factory HelpBlockDto.fromJson(Map<String, Object?> json) => _$HelpBlockDtoFromJson(json);
  
  final HelpBlockDtoType type;
  final String? text;
  final String? title;
  final String? attribution;

  Map<String, Object?> toJson() => _$HelpBlockDtoToJson(this);
}
