// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_listing_report_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminListingReportDto _$AdminListingReportDtoFromJson(
  Map<String, dynamic> json,
) => AdminListingReportDto(
  id: json['id'] as String,
  listingId: json['listingId'] as String,
  listingTitle: json['listingTitle'] as String,
  listingStatus: ListingStatus.fromJson(json['listingStatus'] as String),
  sellerName: json['sellerName'] as String,
  reporterName: json['reporterName'] as String,
  reason: ReportReason.fromJson(json['reason'] as String),
  status: ListingReportStatus.fromJson(json['status'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  note: json['note'] as String?,
  resolution: json['resolution'] as String?,
);

Map<String, dynamic> _$AdminListingReportDtoToJson(
  AdminListingReportDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'listingId': instance.listingId,
  'listingTitle': instance.listingTitle,
  'listingStatus': instance.listingStatus,
  'sellerName': instance.sellerName,
  'reporterName': instance.reporterName,
  'reason': instance.reason,
  'note': instance.note,
  'status': instance.status,
  'resolution': instance.resolution,
  'createdAt': instance.createdAt.toIso8601String(),
};
