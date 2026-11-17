// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_opportunity_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyOpportunityDto _$MyOpportunityDtoFromJson(Map<String, dynamic> json) =>
    MyOpportunityDto(
      opportunity: OpportunityCardDto.fromJson(
        json['opportunity'] as Map<String, dynamic>,
      ),
      tracking: TrackingStateDto.fromJson(
        json['tracking'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$MyOpportunityDtoToJson(MyOpportunityDto instance) =>
    <String, dynamic>{
      'opportunity': instance.opportunity,
      'tracking': instance.tracking,
    };
