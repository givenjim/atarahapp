// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_reports_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserReportsDto _$UserReportsDtoFromJson(Map<String, dynamic> json) =>
    UserReportsDto(
      about: json['about'] as num,
      made: json['made'] as num,
      recent: (json['recent'] as List<dynamic>)
          .map((e) => UserReportDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserReportsDtoToJson(UserReportsDto instance) =>
    <String, dynamic>{
      'about': instance.about,
      'made': instance.made,
      'recent': instance.recent,
    };
