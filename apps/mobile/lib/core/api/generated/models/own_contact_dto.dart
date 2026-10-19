// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'own_contact_dto.g.dart';

@JsonSerializable()
class OwnContactDto {
  const OwnContactDto({
    required this.email,
    required this.phone,
    required this.showEmail,
    required this.showPhone,
    required this.forConnections,
  });

  factory OwnContactDto.fromJson(Map<String, Object?> json) =>
      _$OwnContactDtoFromJson(json);

  final String? email;
  final String? phone;
  final bool showEmail;
  final bool showPhone;
  final bool forConnections;

  Map<String, Object?> toJson() => _$OwnContactDtoToJson(this);
}
