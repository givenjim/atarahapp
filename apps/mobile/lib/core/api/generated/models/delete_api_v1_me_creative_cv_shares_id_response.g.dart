// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_api_v1_me_creative_cv_shares_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteApiV1MeCreativeCvSharesIdResponse
_$DeleteApiV1MeCreativeCvSharesIdResponseFromJson(Map<String, dynamic> json) =>
    DeleteApiV1MeCreativeCvSharesIdResponse(
      data: CvShareDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$DeleteApiV1MeCreativeCvSharesIdResponseToJson(
  DeleteApiV1MeCreativeCvSharesIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
