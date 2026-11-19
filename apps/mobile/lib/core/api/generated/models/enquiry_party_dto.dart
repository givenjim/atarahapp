// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'enquiry_party_dto.g.dart';

@JsonSerializable()
class EnquiryPartyDto {
  const EnquiryPartyDto({
    required this.userId,
    required this.displayName,
    this.handle,
    this.avatarUrl,
  });
  
  factory EnquiryPartyDto.fromJson(Map<String, Object?> json) => _$EnquiryPartyDtoFromJson(json);
  
  final String userId;
  final String displayName;
  final String? handle;
  final String? avatarUrl;

  Map<String, Object?> toJson() => _$EnquiryPartyDtoToJson(this);
}
