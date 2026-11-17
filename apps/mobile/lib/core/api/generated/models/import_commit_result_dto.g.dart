// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_commit_result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportCommitResultDto _$ImportCommitResultDtoFromJson(
  Map<String, dynamic> json,
) => ImportCommitResultDto(
  created: json['created'] as num,
  skipped: json['skipped'] as num,
  status: json['status'] as String,
  issues: (json['issues'] as List<dynamic>)
      .map((e) => ImportIssueDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ImportCommitResultDtoToJson(
  ImportCommitResultDto instance,
) => <String, dynamic>{
  'created': instance.created,
  'skipped': instance.skipped,
  'status': instance.status,
  'issues': instance.issues,
};
