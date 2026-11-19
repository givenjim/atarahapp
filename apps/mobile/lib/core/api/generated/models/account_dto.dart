// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'account_dto.g.dart';

@JsonSerializable()
class AccountDto {
  const AccountDto({
    required this.fullName,
    required this.emailVerified,
    required this.phoneVerified,
    this.handle,
    this.email,
    this.phone,
    this.pendingEmail,
    this.pendingPhone,
  });
  
  factory AccountDto.fromJson(Map<String, Object?> json) => _$AccountDtoFromJson(json);
  
  final String fullName;

  /// The public username (handle).
  final String? handle;
  final String? email;
  final bool emailVerified;

  /// E.164
  final String? phone;
  final bool phoneVerified;

  /// A new email waiting for confirmation.
  final String? pendingEmail;

  /// A new phone waiting for its code.
  final String? pendingPhone;

  Map<String, Object?> toJson() => _$AccountDtoToJson(this);
}
