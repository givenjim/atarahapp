// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'enquiry_message_dto.g.dart';

@JsonSerializable()
class EnquiryMessageDto {
  const EnquiryMessageDto({
    required this.id,
    required this.senderId,
    required this.body,
    required this.fromMe,
    required this.createdAt,
  });
  
  factory EnquiryMessageDto.fromJson(Map<String, Object?> json) => _$EnquiryMessageDtoFromJson(json);
  
  final String id;
  final String senderId;
  final String body;

  /// Sent by the person asking.
  final bool fromMe;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$EnquiryMessageDtoToJson(this);
}
