// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enquiry_thread_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnquiryThreadDto _$EnquiryThreadDtoFromJson(Map<String, dynamic> json) =>
    EnquiryThreadDto(
      id: json['id'] as String,
      listingId: json['listingId'] as String,
      listingTitle: json['listingTitle'] as String,
      status: EnquiryStatus.fromJson(json['status'] as String),
      role: EnquiryThreadDtoRole.fromJson(json['role'] as String),
      counterpart: EnquiryPartyDto.fromJson(
        json['counterpart'] as Map<String, dynamic>,
      ),
      message: json['message'] as String,
      unread: json['unread'] as bool,
      lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      canReview: json['canReview'] as bool,
      canClose: json['canClose'] as bool,
      reviewed: json['reviewed'] as bool,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => EnquiryMessageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      listingCoverUrl: json['listingCoverUrl'] as String?,
      budget: json['budget'] as num?,
      preferredTiming: json['preferredTiming'] as String?,
      closedAt: json['closedAt'] == null
          ? null
          : DateTime.parse(json['closedAt'] as String),
    );

Map<String, dynamic> _$EnquiryThreadDtoToJson(EnquiryThreadDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'listingId': instance.listingId,
      'listingTitle': instance.listingTitle,
      'listingCoverUrl': instance.listingCoverUrl,
      'status': instance.status,
      'role': instance.role,
      'counterpart': instance.counterpart,
      'message': instance.message,
      'budget': instance.budget,
      'preferredTiming': instance.preferredTiming,
      'unread': instance.unread,
      'lastMessageAt': instance.lastMessageAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'closedAt': instance.closedAt?.toIso8601String(),
      'canReview': instance.canReview,
      'canClose': instance.canClose,
      'reviewed': instance.reviewed,
      'messages': instance.messages,
    };
