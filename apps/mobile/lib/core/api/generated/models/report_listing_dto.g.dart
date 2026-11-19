// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_listing_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportListingDto _$ReportListingDtoFromJson(Map<String, dynamic> json) =>
    ReportListingDto(
      reason: ReportReason.fromJson(json['reason'] as String),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$ReportListingDtoToJson(ReportListingDto instance) =>
    <String, dynamic>{'reason': instance.reason, 'note': instance.note};
