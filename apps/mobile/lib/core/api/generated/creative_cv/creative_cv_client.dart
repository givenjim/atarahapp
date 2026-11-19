// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_share_dto.dart';
import '../models/delete_api_v1_me_creative_cv_shares_id_response.dart';
import '../models/get_api_v1_me_creative_cv_format_preview_response.dart';
import '../models/get_api_v1_me_creative_cv_format_response.dart';
import '../models/get_api_v1_me_creative_cv_format_shares_response.dart';
import '../models/get_api_v1_me_creative_cv_formats_response.dart';
import '../models/get_api_v1_me_creative_cv_renders_id_response.dart';
import '../models/post_api_v1_me_creative_cv_format_generate_response.dart';
import '../models/post_api_v1_me_creative_cv_format_shares_response.dart';
import '../models/post_api_v1_me_creative_cv_renders_id_download_response.dart';
import '../models/put_api_v1_me_creative_cv_format_response.dart';
import '../models/update_cv_dto.dart';

part 'creative_cv_client.g.dart';

@RestApi()
abstract class CreativeCvClient {
  factory CreativeCvClient(Dio dio, {String? baseUrl}) = _CreativeCvClient;

  @GET('/api/v1/me/creative-cv/formats')
  Future<GetApiV1MeCreativeCvFormatsResponse> formats();

  @DELETE('/api/v1/me/creative-cv/shares/{id}')
  Future<DeleteApiV1MeCreativeCvSharesIdResponse> revokeShare({
    @Path('id') required String id,
  });

  @GET('/api/v1/me/creative-cv/renders/{id}')
  Future<GetApiV1MeCreativeCvRendersIdResponse> renderStatus({
    @Path('id') required String id,
  });

  @POST('/api/v1/me/creative-cv/renders/{id}/download')
  Future<PostApiV1MeCreativeCvRendersIdDownloadResponse> download({
    @Path('id') required String id,
  });

  @GET('/api/v1/me/creative-cv/{format}')
  Future<GetApiV1MeCreativeCvFormatResponse> state({
    @Path('format') required String format,
  });

  @PUT('/api/v1/me/creative-cv/{format}')
  Future<PutApiV1MeCreativeCvFormatResponse> update({
    @Path('format') required String format,
    @Body() required UpdateCvDto body,
  });

  @GET('/api/v1/me/creative-cv/{format}/preview')
  Future<GetApiV1MeCreativeCvFormatPreviewResponse> preview({
    @Path('format') required String format,
  });

  @POST('/api/v1/me/creative-cv/{format}/generate')
  Future<PostApiV1MeCreativeCvFormatGenerateResponse> generate({
    @Path('format') required String format,
  });

  @GET('/api/v1/me/creative-cv/{format}/shares')
  Future<GetApiV1MeCreativeCvFormatSharesResponse> shares({
    @Path('format') required String format,
  });

  @POST('/api/v1/me/creative-cv/{format}/shares')
  Future<PostApiV1MeCreativeCvFormatSharesResponse> createShare({
    @Path('format') required String format,
    @Body() required CreateShareDto body,
  });
}
