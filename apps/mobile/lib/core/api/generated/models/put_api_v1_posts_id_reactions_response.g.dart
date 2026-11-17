// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_api_v1_posts_id_reactions_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutApiV1PostsIdReactionsResponse _$PutApiV1PostsIdReactionsResponseFromJson(
  Map<String, dynamic> json,
) => PutApiV1PostsIdReactionsResponse(
  data: ReactionStateDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PutApiV1PostsIdReactionsResponseToJson(
  PutApiV1PostsIdReactionsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
