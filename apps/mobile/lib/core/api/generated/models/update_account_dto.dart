// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'update_account_dto.g.dart';

@JsonSerializable()
class UpdateAccountDto {
  const UpdateAccountDto({
    this.fullName,
    this.handle,
  });
  
  factory UpdateAccountDto.fromJson(Map<String, Object?> json) => _$UpdateAccountDtoFromJson(json);
  
  final String? fullName;

  /// Lower-case letters, digits and underscores, 3 to 30 characters.
  final String? handle;

  Map<String, Object?> toJson() => _$UpdateAccountDtoToJson(this);
}
