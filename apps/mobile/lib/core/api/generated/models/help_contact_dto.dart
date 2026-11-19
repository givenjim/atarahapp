// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'help_contact_dto.g.dart';

@JsonSerializable()
class HelpContactDto {
  const HelpContactDto({
    required this.email,
    required this.note,
  });
  
  factory HelpContactDto.fromJson(Map<String, Object?> json) => _$HelpContactDtoFromJson(json);
  
  /// Where "Chat with us" sends the member: a support email.
  final String email;
  final String note;

  Map<String, Object?> toJson() => _$HelpContactDtoToJson(this);
}
