// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplicationItemDto _$ApplicationItemDtoFromJson(Map<String, dynamic> json) =>
    ApplicationItemDto(
      opportunity: OpportunityCardDto.fromJson(
        json['opportunity'] as Map<String, dynamic>,
      ),
      tracking: TrackingStateDto.fromJson(
        json['tracking'] as Map<String, dynamic>,
      ),
      status: ApplicationItemDtoStatus.fromJson(json['status'] as String),
      metaLine: json['metaLine'] as String,
    );

Map<String, dynamic> _$ApplicationItemDtoToJson(ApplicationItemDto instance) =>
    <String, dynamic>{
      'opportunity': instance.opportunity,
      'tracking': instance.tracking,
      'status': instance.status,
      'metaLine': instance.metaLine,
    };
