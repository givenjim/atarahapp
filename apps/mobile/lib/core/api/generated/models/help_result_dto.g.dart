// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'help_result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HelpResultDto _$HelpResultDtoFromJson(Map<String, dynamic> json) =>
    HelpResultDto(
      articles: (json['articles'] as List<dynamic>)
          .map((e) => HelpArticleCardDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      faq: (json['faq'] as List<dynamic>)
          .map((e) => FaqDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HelpResultDtoToJson(HelpResultDto instance) =>
    <String, dynamic>{'articles': instance.articles, 'faq': instance.faq};
