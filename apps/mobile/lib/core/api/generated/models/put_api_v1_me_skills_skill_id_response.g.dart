// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_api_v1_me_skills_skill_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutApiV1MeSkillsSkillIdResponse _$PutApiV1MeSkillsSkillIdResponseFromJson(
  Map<String, dynamic> json,
) => PutApiV1MeSkillsSkillIdResponse(
  data: SkillEntryDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PutApiV1MeSkillsSkillIdResponseToJson(
  PutApiV1MeSkillsSkillIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
