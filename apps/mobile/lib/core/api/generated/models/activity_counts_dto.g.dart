// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_counts_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityCountsDto _$ActivityCountsDtoFromJson(Map<String, dynamic> json) =>
    ActivityCountsDto(
      saved: json['saved'] as num,
      applications: json['applications'] as num,
      unreadNotifications: json['unreadNotifications'] as num,
      learningInProgress: json['learningInProgress'] as num,
      portfolio: json['portfolio'] as num,
      pendingConnections: json['pendingConnections'] as num,
    );

Map<String, dynamic> _$ActivityCountsDtoToJson(ActivityCountsDto instance) =>
    <String, dynamic>{
      'saved': instance.saved,
      'applications': instance.applications,
      'unreadNotifications': instance.unreadNotifications,
      'learningInProgress': instance.learningInProgress,
      'portfolio': instance.portfolio,
      'pendingConnections': instance.pendingConnections,
    };
