// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'learning_card_dto.dart';

part 'my_learning_item_dto.g.dart';

@JsonSerializable()
class MyLearningItemDto {
  const MyLearningItemDto({required this.content, this.lastActivityAt});

  factory MyLearningItemDto.fromJson(Map<String, Object?> json) =>
      _$MyLearningItemDtoFromJson(json);

  final LearningCardDto content;
  final DateTime? lastActivityAt;

  Map<String, Object?> toJson() => _$MyLearningItemDtoToJson(this);
}
