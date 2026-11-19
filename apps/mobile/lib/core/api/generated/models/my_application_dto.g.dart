// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_application_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyApplicationDto _$MyApplicationDtoFromJson(Map<String, dynamic> json) =>
    MyApplicationDto(
      canApply: json['canApply'] as bool,
      latest: json['latest'] == null
          ? null
          : MentorApplicationDto.fromJson(
              json['latest'] as Map<String, dynamic>,
            ),
      cannotApplyReason: json['cannotApplyReason'] as String?,
    );

Map<String, dynamic> _$MyApplicationDtoToJson(MyApplicationDto instance) =>
    <String, dynamic>{
      'latest': instance.latest,
      'canApply': instance.canApply,
      'cannotApplyReason': instance.cannotApplyReason,
    };
