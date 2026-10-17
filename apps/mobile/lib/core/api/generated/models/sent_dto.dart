// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'sent_dto.g.dart';

@JsonSerializable()
class SentDto {
  const SentDto({required this.sent});

  factory SentDto.fromJson(Map<String, Object?> json) =>
      _$SentDtoFromJson(json);

  final bool sent;

  Map<String, Object?> toJson() => _$SentDtoToJson(this);
}
