// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_feature_flags_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminFeatureFlagsResponse _$GetApiV1AdminFeatureFlagsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminFeatureFlagsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => FeatureFlagDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminFeatureFlagsResponseToJson(
  GetApiV1AdminFeatureFlagsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
