// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_applications_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeApplicationsResponse _$GetApiV1MeApplicationsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeApplicationsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => ApplicationItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeApplicationsResponseToJson(
  GetApiV1MeApplicationsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
