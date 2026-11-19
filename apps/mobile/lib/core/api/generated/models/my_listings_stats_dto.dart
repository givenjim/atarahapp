// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'my_listings_stats_dto.g.dart';

@JsonSerializable()
class MyListingsStatsDto {
  const MyListingsStatsDto({
    required this.live,
    required this.newInterest,
    required this.views30d,
  });
  
  factory MyListingsStatsDto.fromJson(Map<String, Object?> json) => _$MyListingsStatsDtoFromJson(json);
  
  final num live;
  final num newInterest;
  final num views30d;

  Map<String, Object?> toJson() => _$MyListingsStatsDtoToJson(this);
}
