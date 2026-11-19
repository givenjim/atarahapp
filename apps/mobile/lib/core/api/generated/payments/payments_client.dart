// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_api_v1_payments_id_response.dart';
import '../models/get_api_v1_payments_methods_response.dart';
import '../models/get_api_v1_payments_response.dart';
import '../models/initiate_payment_dto.dart';
import '../models/post_api_v1_payments_response.dart';

part 'payments_client.g.dart';

@RestApi()
abstract class PaymentsClient {
  factory PaymentsClient(Dio dio, {String? baseUrl}) = _PaymentsClient;

  @GET('/api/v1/payments/methods')
  Future<GetApiV1PaymentsMethodsResponse> methods();

  @GET('/api/v1/payments')
  Future<GetApiV1PaymentsResponse> list({
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  /// [idempotencyKey] - A fresh UUID per attempt (8 to 128 characters).
  @POST('/api/v1/payments')
  Future<PostApiV1PaymentsResponse> initiate({
    @Header('Idempotency-Key') required String idempotencyKey,
    @Body() required InitiatePaymentDto body,
  });

  /// null.
  ///
  /// The name has been replaced because it contains a keyword. Original name: `get`.
  @GET('/api/v1/payments/{id}')
  Future<GetApiV1PaymentsIdResponse> getApiV1PaymentsId({
    @Path('id') required String id,
  });
}
