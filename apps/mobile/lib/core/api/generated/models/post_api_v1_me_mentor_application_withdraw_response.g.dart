// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_mentor_application_withdraw_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeMentorApplicationWithdrawResponse
_$PostApiV1MeMentorApplicationWithdrawResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MeMentorApplicationWithdrawResponse(
  data: MentorApplicationDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MeMentorApplicationWithdrawResponseToJson(
  PostApiV1MeMentorApplicationWithdrawResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
