// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivacyRequestDto _$PrivacyRequestDtoFromJson(Map<String, dynamic> json) =>
    PrivacyRequestDto(
      kind: PrivacyRequestDtoKind.fromJson(json['kind'] as String),
      id: json['id'] as String,
      userId: json['userId'] as String,
      status: json['status'] as String,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      memberName: json['memberName'] as String?,
      dueAt: json['dueAt'] == null
          ? null
          : DateTime.parse(json['dueAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$PrivacyRequestDtoToJson(PrivacyRequestDto instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'id': instance.id,
      'userId': instance.userId,
      'memberName': instance.memberName,
      'status': instance.status,
      'requestedAt': instance.requestedAt.toIso8601String(),
      'dueAt': instance.dueAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };
