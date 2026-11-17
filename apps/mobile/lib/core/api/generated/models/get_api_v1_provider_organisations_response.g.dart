// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_provider_organisations_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1ProviderOrganisationsResponse
_$GetApiV1ProviderOrganisationsResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1ProviderOrganisationsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => AdminProviderDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1ProviderOrganisationsResponseToJson(
  GetApiV1ProviderOrganisationsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
