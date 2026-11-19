// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'create_share_dto.g.dart';

@JsonSerializable()
class CreateShareDto {
  const CreateShareDto({
    this.expiresInDays,
  });
  
  factory CreateShareDto.fromJson(Map<String, Object?> json) => _$CreateShareDtoFromJson(json);
  
  /// The link stops working after this many days. Omit for no expiry.
  final num? expiresInDays;

  Map<String, Object?> toJson() => _$CreateShareDtoToJson(this);
}
