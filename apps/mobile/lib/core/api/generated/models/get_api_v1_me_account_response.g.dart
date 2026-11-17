// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_account_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeAccountResponse _$GetApiV1MeAccountResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeAccountResponse(
  data: AccountDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeAccountResponseToJson(
  GetApiV1MeAccountResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
