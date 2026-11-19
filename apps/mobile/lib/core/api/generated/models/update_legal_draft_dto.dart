// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'update_legal_draft_dto.g.dart';

@JsonSerializable()
class UpdateLegalDraftDto {
  const UpdateLegalDraftDto({
    this.title,
    this.body,
  });
  
  factory UpdateLegalDraftDto.fromJson(Map<String, Object?> json) => _$UpdateLegalDraftDtoFromJson(json);
  
  final String? title;
  final String? body;

  Map<String, Object?> toJson() => _$UpdateLegalDraftDtoToJson(this);
}
