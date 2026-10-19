// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'discipline_lite.dart';

part 'creative_card_dto.g.dart';

@JsonSerializable()
class CreativeCardDto {
  const CreativeCardDto({
    required this.handle,
    required this.displayName,
    required this.tags,
    required this.verified,
    required this.openToCommissions,
    this.headline,
    this.avatarUrl,
    this.discipline,
    this.location,
    this.reason,
  });

  factory CreativeCardDto.fromJson(Map<String, Object?> json) =>
      _$CreativeCardDtoFromJson(json);

  final String handle;
  final String displayName;
  final String? headline;
  final String? avatarUrl;
  final DisciplineLite? discipline;

  /// Up to three skills, only when the member shows them.
  final List<String> tags;

  /// County, only when the member shows it to you.
  final String? location;

  /// Verified by Atarah.
  final bool verified;
  final bool openToCommissions;

  /// Why this person is suggested.
  final String? reason;

  Map<String, Object?> toJson() => _$CreativeCardDtoToJson(this);
}
