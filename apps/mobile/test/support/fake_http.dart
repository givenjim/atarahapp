import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Scriptable HTTP layer: each request is answered by [handler].
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(int status, Object body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

Map<String, Object?> errorBody(
  String code,
  int status, {
  Map<String, Object?> details = const {},
}) => {
  'error': {
    'code': code,
    'message': 'msg $code',
    'details': details,
    'requestId': 'rid-1',
  },
};
