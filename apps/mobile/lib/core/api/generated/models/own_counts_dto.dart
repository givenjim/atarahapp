// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'own_counts_dto.g.dart';

@JsonSerializable()
class OwnCountsDto {
  const OwnCountsDto({
    required this.skills,
    required this.connections,
    required this.pendingRequests,
  });

  factory OwnCountsDto.fromJson(Map<String, Object?> json) =>
      _$OwnCountsDtoFromJson(json);

  final num skills;

  /// Accepted connections.
  final num connections;

  /// Requests waiting for the member to answer.
  final num pendingRequests;

  Map<String, Object?> toJson() => _$OwnCountsDtoToJson(this);
}
