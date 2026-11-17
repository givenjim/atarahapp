// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_privacy_requests_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminPrivacyRequestsResponse
_$GetApiV1AdminPrivacyRequestsResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1AdminPrivacyRequestsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => PrivacyRequestDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1AdminPrivacyRequestsResponseToJson(
  GetApiV1AdminPrivacyRequestsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
