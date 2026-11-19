// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'admin_payer_dto.g.dart';

@JsonSerializable()
class AdminPayerDto {
  const AdminPayerDto({
    required this.id,
    required this.fullName,
  });
  
  factory AdminPayerDto.fromJson(Map<String, Object?> json) => _$AdminPayerDtoFromJson(json);
  
  final String id;
  final String fullName;

  Map<String, Object?> toJson() => _$AdminPayerDtoToJson(this);
}
