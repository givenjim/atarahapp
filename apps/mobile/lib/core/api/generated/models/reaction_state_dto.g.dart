// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction_state_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReactionStateDto _$ReactionStateDtoFromJson(Map<String, dynamic> json) =>
    ReactionStateDto(
      reacted: json['reacted'] as bool,
      reactionCount: json['reactionCount'] as num,
    );

Map<String, dynamic> _$ReactionStateDtoToJson(ReactionStateDto instance) =>
    <String, dynamic>{
      'reacted': instance.reacted,
      'reactionCount': instance.reactionCount,
    };
