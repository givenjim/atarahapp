// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'deletion_state_dto.g.dart';

@JsonSerializable()
class DeletionStateDto {
  const DeletionStateDto({
    required this.purgeAfter,
    required this.sessionsRevoked,
  });
  
  factory DeletionStateDto.fromJson(Map<String, Object?> json) => _$DeletionStateDtoFromJson(json);
  
  /// Personal data is deleted after this.
  final DateTime purgeAfter;
  final num sessionsRevoked;

  Map<String, Object?> toJson() => _$DeletionStateDtoToJson(this);
}
