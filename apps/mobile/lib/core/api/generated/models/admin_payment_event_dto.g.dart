// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_payment_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminPaymentEventDto _$AdminPaymentEventDtoFromJson(
  Map<String, dynamic> json,
) => AdminPaymentEventDto(
  id: json['id'] as String,
  kind: AdminPaymentEventDtoKind.fromJson(json['kind'] as String),
  source: AdminPaymentEventDtoSource.fromJson(json['source'] as String),
  fromStatus: json['fromStatus'] == null
      ? null
      : AdminPaymentEventDtoFromStatus.fromJson(json['fromStatus'] as String),
  toStatus: json['toStatus'] == null
      ? null
      : AdminPaymentEventDtoToStatus.fromJson(json['toStatus'] as String),
  summary: json['summary'] as String,
  actorId: json['actorId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$AdminPaymentEventDtoToJson(
  AdminPaymentEventDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'kind': instance.kind,
  'source': instance.source,
  'fromStatus': instance.fromStatus,
  'toStatus': instance.toStatus,
  'summary': instance.summary,
  'actorId': instance.actorId,
  'createdAt': instance.createdAt.toIso8601String(),
};
