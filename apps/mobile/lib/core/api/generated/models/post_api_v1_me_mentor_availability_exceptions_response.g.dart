// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_mentor_availability_exceptions_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeMentorAvailabilityExceptionsResponse
_$PostApiV1MeMentorAvailabilityExceptionsResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MeMentorAvailabilityExceptionsResponse(
  data: ExceptionDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MeMentorAvailabilityExceptionsResponseToJson(
  PostApiV1MeMentorAvailabilityExceptionsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
