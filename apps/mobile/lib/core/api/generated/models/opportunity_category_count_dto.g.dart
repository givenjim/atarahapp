// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opportunity_category_count_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpportunityCategoryCountDto _$OpportunityCategoryCountDtoFromJson(
  Map<String, dynamic> json,
) => OpportunityCategoryCountDto(
  type: OpportunityType.fromJson(json['type'] as String),
  count: json['count'] as num,
);

Map<String, dynamic> _$OpportunityCategoryCountDtoToJson(
  OpportunityCategoryCountDto instance,
) => <String, dynamic>{'type': instance.type, 'count': instance.count};
