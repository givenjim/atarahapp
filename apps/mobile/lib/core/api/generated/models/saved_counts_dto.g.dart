// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_counts_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SavedCountsDto _$SavedCountsDtoFromJson(Map<String, dynamic> json) =>
    SavedCountsDto(
      total: json['total'] as num,
      byType: Map<String, num>.from(json['byType'] as Map),
    );

Map<String, dynamic> _$SavedCountsDtoToJson(SavedCountsDto instance) =>
    <String, dynamic>{'total': instance.total, 'byType': instance.byType};
