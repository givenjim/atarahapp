// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_learning_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyLearningItemDto _$MyLearningItemDtoFromJson(Map<String, dynamic> json) =>
    MyLearningItemDto(
      content: LearningCardDto.fromJson(
        json['content'] as Map<String, dynamic>,
      ),
      lastActivityAt: json['lastActivityAt'] == null
          ? null
          : DateTime.parse(json['lastActivityAt'] as String),
    );

Map<String, dynamic> _$MyLearningItemDtoToJson(MyLearningItemDto instance) =>
    <String, dynamic>{
      'content': instance.content,
      'lastActivityAt': instance.lastActivityAt?.toIso8601String(),
    };
