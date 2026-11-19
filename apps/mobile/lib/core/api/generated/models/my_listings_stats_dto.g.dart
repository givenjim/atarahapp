// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_listings_stats_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyListingsStatsDto _$MyListingsStatsDtoFromJson(Map<String, dynamic> json) =>
    MyListingsStatsDto(
      live: json['live'] as num,
      newInterest: json['newInterest'] as num,
      views30d: json['views30d'] as num,
    );

Map<String, dynamic> _$MyListingsStatsDtoToJson(MyListingsStatsDto instance) =>
    <String, dynamic>{
      'live': instance.live,
      'newInterest': instance.newInterest,
      'views30d': instance.views30d,
    };
