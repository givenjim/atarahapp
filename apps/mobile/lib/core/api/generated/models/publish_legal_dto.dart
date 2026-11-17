// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'publish_legal_dto.g.dart';

@JsonSerializable()
class PublishLegalDto {
  const PublishLegalDto({this.effectiveAt});

  factory PublishLegalDto.fromJson(Map<String, Object?> json) =>
      _$PublishLegalDtoFromJson(json);

  /// When it takes effect. Defaults to now.
  final DateTime? effectiveAt;

  Map<String, Object?> toJson() => _$PublishLegalDtoToJson(this);
}
