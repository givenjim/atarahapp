// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'send_enquiry_message_dto.g.dart';

@JsonSerializable()
class SendEnquiryMessageDto {
  const SendEnquiryMessageDto({
    required this.body,
  });
  
  factory SendEnquiryMessageDto.fromJson(Map<String, Object?> json) => _$SendEnquiryMessageDtoFromJson(json);
  
  final String body;

  Map<String, Object?> toJson() => _$SendEnquiryMessageDtoToJson(this);
}
