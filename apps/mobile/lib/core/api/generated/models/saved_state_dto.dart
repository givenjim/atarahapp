// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'saved_state_dto.g.dart';

@JsonSerializable()
class SavedStateDto {
  const SavedStateDto({
    required this.saved,
  });
  
  factory SavedStateDto.fromJson(Map<String, Object?> json) => _$SavedStateDtoFromJson(json);
  
  final bool saved;

  Map<String, Object?> toJson() => _$SavedStateDtoToJson(this);
}
