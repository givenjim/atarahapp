// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'reaction_state_dto.g.dart';

@JsonSerializable()
class ReactionStateDto {
  const ReactionStateDto({
    required this.reacted,
    required this.reactionCount,
  });
  
  factory ReactionStateDto.fromJson(Map<String, Object?> json) => _$ReactionStateDtoFromJson(json);
  
  final bool reacted;
  final num reactionCount;

  Map<String, Object?> toJson() => _$ReactionStateDtoToJson(this);
}
