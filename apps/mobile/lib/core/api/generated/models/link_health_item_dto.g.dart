// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_health_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinkHealthItemDto _$LinkHealthItemDtoFromJson(Map<String, dynamic> json) =>
    LinkHealthItemDto(
      opportunityId: json['opportunityId'] as String,
      title: json['title'] as String,
      provider: json['provider'] as String,
      status: OpportunityStatus.fromJson(json['status'] as String),
      linkStatus: LinkHealthItemDtoLinkStatus.fromJson(
        json['linkStatus'] as String,
      ),
      applicationUrl: json['applicationUrl'] as String?,
      httpStatus: json['httpStatus'] as num?,
      error: json['error'] as String?,
      checkedAt: json['checkedAt'] == null
          ? null
          : DateTime.parse(json['checkedAt'] as String),
    );

Map<String, dynamic> _$LinkHealthItemDtoToJson(LinkHealthItemDto instance) =>
    <String, dynamic>{
      'opportunityId': instance.opportunityId,
      'title': instance.title,
      'provider': instance.provider,
      'status': instance.status,
      'applicationUrl': instance.applicationUrl,
      'linkStatus': instance.linkStatus,
      'httpStatus': instance.httpStatus,
      'error': instance.error,
      'checkedAt': instance.checkedAt?.toIso8601String(),
    };
