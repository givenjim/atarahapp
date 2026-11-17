// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'verify_phone_change_dto.g.dart';

@JsonSerializable()
class VerifyPhoneChangeDto {
  const VerifyPhoneChangeDto({required this.phone, required this.code});

  factory VerifyPhoneChangeDto.fromJson(Map<String, Object?> json) =>
      _$VerifyPhoneChangeDtoFromJson(json);

  final String phone;
  final String code;

  Map<String, Object?> toJson() => _$VerifyPhoneChangeDtoToJson(this);
}
