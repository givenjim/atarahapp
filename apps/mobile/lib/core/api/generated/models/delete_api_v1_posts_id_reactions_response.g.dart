// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_api_v1_posts_id_reactions_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteApiV1PostsIdReactionsResponse
_$DeleteApiV1PostsIdReactionsResponseFromJson(Map<String, dynamic> json) =>
    DeleteApiV1PostsIdReactionsResponse(
      data: ReactionStateDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$DeleteApiV1PostsIdReactionsResponseToJson(
  DeleteApiV1PostsIdReactionsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
