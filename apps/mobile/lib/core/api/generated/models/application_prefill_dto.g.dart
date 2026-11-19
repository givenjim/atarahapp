// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_prefill_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplicationPrefillDto _$ApplicationPrefillDtoFromJson(
  Map<String, dynamic> json,
) => ApplicationPrefillDto(
  headline: json['headline'] as String,
  yearsExperience: json['yearsExperience'] as num,
  expertiseTags: (json['expertiseTags'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  disciplineIds: (json['disciplineIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  credentials: (json['credentials'] as List<dynamic>)
      .map((e) => CredentialOutDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  statement: json['statement'] as String,
  timeZone: json['timeZone'] as String,
  profileReady: json['profileReady'] as bool,
);

Map<String, dynamic> _$ApplicationPrefillDtoToJson(
  ApplicationPrefillDto instance,
) => <String, dynamic>{
  'headline': instance.headline,
  'yearsExperience': instance.yearsExperience,
  'expertiseTags': instance.expertiseTags,
  'disciplineIds': instance.disciplineIds,
  'credentials': instance.credentials,
  'statement': instance.statement,
  'timeZone': instance.timeZone,
  'profileReady': instance.profileReady,
};
