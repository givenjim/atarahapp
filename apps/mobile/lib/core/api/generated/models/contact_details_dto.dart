// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'contact_details_dto.g.dart';

@JsonSerializable()
class ContactDetailsDto {
  const ContactDetailsDto({required this.email, required this.phone});

  factory ContactDetailsDto.fromJson(Map<String, Object?> json) =>
      _$ContactDetailsDtoFromJson(json);

  final String? email;
  final String? phone;

  Map<String, Object?> toJson() => _$ContactDetailsDtoToJson(this);
}
