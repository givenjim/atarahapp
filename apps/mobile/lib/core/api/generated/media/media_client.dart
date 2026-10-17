// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_api_v1_media_id_response.dart';
import '../models/post_api_v1_media_id_complete_response.dart';
import '../models/post_api_v1_media_uploads_response.dart';
import '../models/request_upload_dto.dart';

part 'media_client.g.dart';

@RestApi()
abstract class MediaClient {
  factory MediaClient(Dio dio, {String? baseUrl}) = _MediaClient;

  @POST('/api/v1/media/uploads')
  Future<PostApiV1MediaUploadsResponse> requestUpload({
    @Body() required RequestUploadDto body,
  });

  @POST('/api/v1/media/{id}/complete')
  Future<PostApiV1MediaIdCompleteResponse> complete({
    @Path('id') required String id,
  });

  /// null.
  ///
  /// The name has been replaced because it contains a keyword. Original name: `get`.
  @GET('/api/v1/media/{id}')
  Future<GetApiV1MediaIdResponse> getApiV1MediaId({
    @Path('id') required String id,
  });

  @DELETE('/api/v1/media/{id}')
  Future<void> remove({@Path('id') required String id});
}
