// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_api_v1_me_cv_shares_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteApiV1MeCvSharesIdResponse _$DeleteApiV1MeCvSharesIdResponseFromJson(
  Map<String, dynamic> json,
) => DeleteApiV1MeCvSharesIdResponse(
  data: CvShareDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$DeleteApiV1MeCvSharesIdResponseToJson(
  DeleteApiV1MeCvSharesIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
