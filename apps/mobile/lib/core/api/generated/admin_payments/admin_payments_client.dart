// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/complete_refund_dto.dart';
import '../models/get_api_v1_admin_payments_id_response.dart';
import '../models/get_api_v1_admin_payments_response.dart';
import '../models/payment_method.dart';
import '../models/post_api_v1_admin_payments_id_refunds_refund_id_cancel_response.dart';
import '../models/post_api_v1_admin_payments_id_refunds_refund_id_complete_response.dart';
import '../models/post_api_v1_admin_payments_id_refunds_response.dart';
import '../models/post_api_v1_admin_payments_id_requery_response.dart';
import '../models/purpose.dart';
import '../models/refund_payment_dto.dart';
import '../models/status4.dart';

part 'admin_payments_client.g.dart';

@RestApi()
abstract class AdminPaymentsClient {
  factory AdminPaymentsClient(Dio dio, {String? baseUrl}) = _AdminPaymentsClient;

  /// [q] - Payment id, M-Pesa receipt or provider reference (exact), or the payer name.
  @GET('/api/v1/admin/payments')
  Future<GetApiV1AdminPaymentsResponse> list({
    @Query('status') Status4? status,
    @Query('paymentMethod') PaymentMethod? paymentMethod,
    @Query('purpose') Purpose? purpose,
    @Query('q') String? q,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @GET('/api/v1/admin/payments/{id}')
  Future<GetApiV1AdminPaymentsIdResponse> detail({
    @Path('id') required String id,
  });

  @POST('/api/v1/admin/payments/{id}/requery')
  Future<PostApiV1AdminPaymentsIdRequeryResponse> requery({
    @Path('id') required String id,
  });

  /// [idempotencyKey] - Repeating a refund request with the same key creates one refund.
  @POST('/api/v1/admin/payments/{id}/refunds')
  Future<PostApiV1AdminPaymentsIdRefundsResponse> refund({
    @Path('id') required String id,
    @Body() required RefundPaymentDto body,
    @Header('Idempotency-Key') String? idempotencyKey,
  });

  @POST('/api/v1/admin/payments/{id}/refunds/{refundId}/complete')
  Future<PostApiV1AdminPaymentsIdRefundsRefundIdCompleteResponse> completeRefund({
    @Path('id') required String id,
    @Path('refundId') required String refundId,
    @Body() required CompleteRefundDto body,
  });

  @POST('/api/v1/admin/payments/{id}/refunds/{refundId}/cancel')
  Future<PostApiV1AdminPaymentsIdRefundsRefundIdCancelResponse> cancelRefund({
    @Path('id') required String id,
    @Path('refundId') required String refundId,
  });
}
