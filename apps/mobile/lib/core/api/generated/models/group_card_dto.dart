// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'group_card_dto_role.dart';
import 'group_type.dart';

part 'group_card_dto.g.dart';

@JsonSerializable()
class GroupCardDto {
  const GroupCardDto({
    required this.id,
    required this.slug,
    required this.type,
    required this.name,
    required this.description,
    required this.coverUrl,
    required this.memberCount,
    required this.isOfficial,
    required this.focus,
    required this.joined,
    required this.role,
  });

  factory GroupCardDto.fromJson(Map<String, Object?> json) =>
      _$GroupCardDtoFromJson(json);

  final String id;
  final String slug;
  final GroupType type;
  final String name;
  final String description;
  final String? coverUrl;
  final num memberCount;

  /// Run by Atarah.
  final bool isOfficial;

  /// Discipline or county the group is about.
  final String? focus;
  final bool joined;
  final GroupCardDtoRole? role;

  Map<String, Object?> toJson() => _$GroupCardDtoToJson(this);
}
