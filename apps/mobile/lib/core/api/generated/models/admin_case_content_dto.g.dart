// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_case_content_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminCaseContentDto _$AdminCaseContentDtoFromJson(Map<String, dynamic> json) =>
    AdminCaseContentDto(
      exists: json['exists'] as bool,
      status: json['status'] == null
          ? null
          : AdminCaseContentDtoStatus.fromJson(json['status'] as String),
      text: json['text'] as String?,
      postId: json['postId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AdminCaseContentDtoToJson(
  AdminCaseContentDto instance,
) => <String, dynamic>{
  'exists': instance.exists,
  'status': instance.status,
  'text': instance.text,
  'postId': instance.postId,
  'createdAt': instance.createdAt?.toIso8601String(),
};
