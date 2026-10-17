// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_taxonomy_client.dart';

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: type=lint
// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main,avoid_redundant_argument_values

class _AdminTaxonomyClient implements AdminTaxonomyClient {
  _AdminTaxonomyClient(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<GetApiV1AdminTaxonomyKindResponse> listTaxonomy({
    required Kind kind,
    String? disciplineId,
    bool? includeArchived,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'disciplineId': disciplineId,
      r'includeArchived': includeArchived,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<GetApiV1AdminTaxonomyKindResponse>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v1/admin/taxonomy/${kind.toJson()}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, Object?>>(_options);
    late GetApiV1AdminTaxonomyKindResponse _value;
    try {
      _value = GetApiV1AdminTaxonomyKindResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PostApiV1AdminTaxonomyKindResponse> createTaxonomy({
    required Kind kind,
    required CreateTaxonomyItemDto body,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options = _setStreamType<PostApiV1AdminTaxonomyKindResponse>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v1/admin/taxonomy/${kind.toJson()}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, Object?>>(_options);
    late PostApiV1AdminTaxonomyKindResponse _value;
    try {
      _value = PostApiV1AdminTaxonomyKindResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PostApiV1AdminTaxonomyKindReorderResponse> reorderTaxonomy({
    required Kind kind,
    required ReorderTaxonomyDto body,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options = _setStreamType<PostApiV1AdminTaxonomyKindReorderResponse>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v1/admin/taxonomy/${kind.toJson()}/reorder',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, Object?>>(_options);
    late PostApiV1AdminTaxonomyKindReorderResponse _value;
    try {
      _value = PostApiV1AdminTaxonomyKindReorderResponse.fromJson(
        _result.data!,
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PatchApiV1AdminTaxonomyKindIdResponse> updateTaxonomy({
    required Kind kind,
    required String id,
    required UpdateTaxonomyItemDto body,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options = _setStreamType<PatchApiV1AdminTaxonomyKindIdResponse>(
      Options(method: 'PATCH', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v1/admin/taxonomy/${kind.toJson()}/${id}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, Object?>>(_options);
    late PatchApiV1AdminTaxonomyKindIdResponse _value;
    try {
      _value = PatchApiV1AdminTaxonomyKindIdResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<GetApiV1AdminSpecialisationSuggestionsResponse> listSuggestions({
    num? page = 1,
    num? limit = 20,
    Status2? status,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'page': page,
      r'limit': limit,
      r'status': status?.toJson(),
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<GetApiV1AdminSpecialisationSuggestionsResponse>(
          Options(method: 'GET', headers: _headers, extra: _extra)
              .compose(
                _dio.options,
                '/api/v1/admin/specialisation-suggestions',
                queryParameters: queryParameters,
                data: _data,
              )
              .copyWith(
                baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
              ),
        );
    final _result = await _dio.fetch<Map<String, Object?>>(_options);
    late GetApiV1AdminSpecialisationSuggestionsResponse _value;
    try {
      _value = GetApiV1AdminSpecialisationSuggestionsResponse.fromJson(
        _result.data!,
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PostApiV1AdminSpecialisationSuggestionsIdApproveResponse>
  approveSuggestion({
    required String id,
    required ApproveSuggestionDto body,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options =
        _setStreamType<
          PostApiV1AdminSpecialisationSuggestionsIdApproveResponse
        >(
          Options(method: 'POST', headers: _headers, extra: _extra)
              .compose(
                _dio.options,
                '/api/v1/admin/specialisation-suggestions/${id}/approve',
                queryParameters: queryParameters,
                data: _data,
              )
              .copyWith(
                baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
              ),
        );
    final _result = await _dio.fetch<Map<String, Object?>>(_options);
    late PostApiV1AdminSpecialisationSuggestionsIdApproveResponse _value;
    try {
      _value =
          PostApiV1AdminSpecialisationSuggestionsIdApproveResponse.fromJson(
            _result.data!,
          );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PostApiV1AdminSpecialisationSuggestionsIdMergeResponse>
  mergeSuggestion({
    required String id,
    required MergeSuggestionDto body,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options =
        _setStreamType<PostApiV1AdminSpecialisationSuggestionsIdMergeResponse>(
          Options(method: 'POST', headers: _headers, extra: _extra)
              .compose(
                _dio.options,
                '/api/v1/admin/specialisation-suggestions/${id}/merge',
                queryParameters: queryParameters,
                data: _data,
              )
              .copyWith(
                baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
              ),
        );
    final _result = await _dio.fetch<Map<String, Object?>>(_options);
    late PostApiV1AdminSpecialisationSuggestionsIdMergeResponse _value;
    try {
      _value = PostApiV1AdminSpecialisationSuggestionsIdMergeResponse.fromJson(
        _result.data!,
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PostApiV1AdminSpecialisationSuggestionsIdRejectResponse>
  rejectSuggestion({
    required String id,
    required RejectSuggestionDto body,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options =
        _setStreamType<PostApiV1AdminSpecialisationSuggestionsIdRejectResponse>(
          Options(method: 'POST', headers: _headers, extra: _extra)
              .compose(
                _dio.options,
                '/api/v1/admin/specialisation-suggestions/${id}/reject',
                queryParameters: queryParameters,
                data: _data,
              )
              .copyWith(
                baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
              ),
        );
    final _result = await _dio.fetch<Map<String, Object?>>(_options);
    late PostApiV1AdminSpecialisationSuggestionsIdRejectResponse _value;
    try {
      _value = PostApiV1AdminSpecialisationSuggestionsIdRejectResponse.fromJson(
        _result.data!,
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}

// dart format on
