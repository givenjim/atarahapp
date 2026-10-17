// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'discipline_lite.g.dart';

@JsonSerializable()
class DisciplineLite {
  const DisciplineLite({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory DisciplineLite.fromJson(Map<String, Object?> json) =>
      _$DisciplineLiteFromJson(json);

  final String id;
  final String name;
  final String icon;

  Map<String, Object?> toJson() => _$DisciplineLiteToJson(this);
}
