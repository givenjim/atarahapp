// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'delete_account_dto.g.dart';

@JsonSerializable()
class DeleteAccountDto {
  const DeleteAccountDto({
    required this.confirm,
    this.password,
  });
  
  factory DeleteAccountDto.fromJson(Map<String, Object?> json) => _$DeleteAccountDtoFromJson(json);
  
  /// Must be the word DELETE.
  final String confirm;

  /// Your password, to prove it is you. Not needed when you signed in within the last 5 minutes.
  final String? password;

  Map<String, Object?> toJson() => _$DeleteAccountDtoToJson(this);
}
