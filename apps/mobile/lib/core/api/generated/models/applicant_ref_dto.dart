// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'applicant_ref_dto.g.dart';

@JsonSerializable()
class ApplicantRefDto {
  const ApplicantRefDto({
    required this.userId,
    required this.displayName,
    this.handle,
    this.email,
  });
  
  factory ApplicantRefDto.fromJson(Map<String, Object?> json) => _$ApplicantRefDtoFromJson(json);
  
  final String userId;
  final String displayName;
  final String? handle;
  final String? email;

  Map<String, Object?> toJson() => _$ApplicantRefDtoToJson(this);
}
