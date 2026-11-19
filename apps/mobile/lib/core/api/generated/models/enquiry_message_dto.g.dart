// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enquiry_message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnquiryMessageDto _$EnquiryMessageDtoFromJson(Map<String, dynamic> json) =>
    EnquiryMessageDto(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      body: json['body'] as String,
      fromMe: json['fromMe'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$EnquiryMessageDtoToJson(EnquiryMessageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'body': instance.body,
      'fromMe': instance.fromMe,
      'createdAt': instance.createdAt.toIso8601String(),
    };
