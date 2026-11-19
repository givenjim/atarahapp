// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_refund_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminRefundDto _$AdminRefundDtoFromJson(Map<String, dynamic> json) =>
    AdminRefundDto(
      id: json['id'] as String,
      amountMinor: json['amountMinor'] as num,
      reason: json['reason'] as String,
      status: AdminRefundDtoStatus.fromJson(json['status'] as String),
      mode: AdminRefundDtoMode.fromJson(json['mode'] as String),
      providerReference: json['providerReference'] as String?,
      failureReason: json['failureReason'] as String?,
      requestedById: json['requestedById'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$AdminRefundDtoToJson(AdminRefundDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amountMinor': instance.amountMinor,
      'reason': instance.reason,
      'status': instance.status,
      'mode': instance.mode,
      'providerReference': instance.providerReference,
      'failureReason': instance.failureReason,
      'requestedById': instance.requestedById,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };
