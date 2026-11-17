// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_membership_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeMembershipResponse _$GetApiV1MeMembershipResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeMembershipResponse(
  data: MembershipViewDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeMembershipResponseToJson(
  GetApiV1MeMembershipResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
