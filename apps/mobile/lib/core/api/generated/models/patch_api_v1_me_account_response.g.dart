// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_me_account_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1MeAccountResponse _$PatchApiV1MeAccountResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1MeAccountResponse(
  data: AccountDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PatchApiV1MeAccountResponseToJson(
  PatchApiV1MeAccountResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
