// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'staff_session_type_dto.g.dart';

@JsonSerializable()
class StaffSessionTypeDto {
  const StaffSessionTypeDto({
    required this.disabled,
    this.note,
  });
  
  factory StaffSessionTypeDto.fromJson(Map<String, Object?> json) => _$StaffSessionTypeDtoFromJson(json);
  
  /// true switches the session type off for members; false allows it again.
  final bool disabled;
  final String? note;

  Map<String, Object?> toJson() => _$StaffSessionTypeDtoToJson(this);
}
