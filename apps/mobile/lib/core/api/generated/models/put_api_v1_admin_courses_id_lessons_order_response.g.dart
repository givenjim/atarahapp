// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_api_v1_admin_courses_id_lessons_order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutApiV1AdminCoursesIdLessonsOrderResponse
_$PutApiV1AdminCoursesIdLessonsOrderResponseFromJson(
  Map<String, dynamic> json,
) => PutApiV1AdminCoursesIdLessonsOrderResponse(
  data: AdminContentDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PutApiV1AdminCoursesIdLessonsOrderResponseToJson(
  PutApiV1AdminCoursesIdLessonsOrderResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
