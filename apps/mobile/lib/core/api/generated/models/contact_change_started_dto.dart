// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'contact_change_started_dto_kind.dart';

part 'contact_change_started_dto.g.dart';

@JsonSerializable()
class ContactChangeStartedDto {
  const ContactChangeStartedDto({
    required this.kind,
    required this.sentTo,
  });
  
  factory ContactChangeStartedDto.fromJson(Map<String, Object?> json) => _$ContactChangeStartedDtoFromJson(json);
  
  final ContactChangeStartedDtoKind kind;

  /// Where the code or confirmation link was sent.
  final String sentTo;

  Map<String, Object?> toJson() => _$ContactChangeStartedDtoToJson(this);
}
