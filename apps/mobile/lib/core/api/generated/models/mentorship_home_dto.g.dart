// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentorship_home_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MentorshipHomeDto _$MentorshipHomeDtoFromJson(
  Map<String, dynamic> json,
) => MentorshipHomeDto(
  canBook: json['canBook'] as bool,
  isMentor: json['isMentor'] as bool,
  topMentors: (json['topMentors'] as List<dynamic>)
      .map((e) => MentorCardDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  applicationStatus: json['applicationStatus'] == null
      ? null
      : MentorApplicationStatus.fromJson(json['applicationStatus'] as String),
  nextSession: json['nextSession'] == null
      ? null
      : NextSessionDto.fromJson(json['nextSession'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MentorshipHomeDtoToJson(MentorshipHomeDto instance) =>
    <String, dynamic>{
      'canBook': instance.canBook,
      'isMentor': instance.isMentor,
      'applicationStatus': instance.applicationStatus,
      'nextSession': instance.nextSession,
      'topMentors': instance.topMentors,
    };
