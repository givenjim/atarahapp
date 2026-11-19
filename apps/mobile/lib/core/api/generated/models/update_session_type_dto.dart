// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'update_session_type_dto.g.dart';

@JsonSerializable()
class UpdateSessionTypeDto {
  const UpdateSessionTypeDto({
    this.name,
    this.description,
    this.durationMinutes,
    this.priceMinor,
    this.sessionCount,
    this.active,
  });
  
  factory UpdateSessionTypeDto.fromJson(Map<String, Object?> json) => _$UpdateSessionTypeDtoFromJson(json);
  
  final String? name;
  final dynamic description;
  final num? durationMinutes;
  final num? priceMinor;
  final num? sessionCount;
  final bool? active;

  Map<String, Object?> toJson() => _$UpdateSessionTypeDtoToJson(this);
}
