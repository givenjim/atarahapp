// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'suspend_user_dto.g.dart';

@JsonSerializable()
class SuspendUserDto {
  const SuspendUserDto({required this.reason, this.durationDays});

  factory SuspendUserDto.fromJson(Map<String, Object?> json) =>
      _$SuspendUserDtoFromJson(json);

  /// Why the account is being suspended. Kept in the audit log.
  final String reason;

  /// Suspend for this many days; the account is reactivated automatically. Omit for until staff lift it.
  final num? durationDays;

  Map<String, Object?> toJson() => _$SuspendUserDtoToJson(this);
}
