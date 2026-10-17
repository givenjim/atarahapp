// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_api_v1_locations_counties_match_response.dart';
import '../models/get_api_v1_locations_counties_response.dart';
import '../models/get_api_v1_locations_countries_response.dart';

part 'locations_client.g.dart';

@RestApi()
abstract class LocationsClient {
  factory LocationsClient(Dio dio, {String? baseUrl}) = _LocationsClient;

  @GET('/api/v1/locations/countries')
  Future<GetApiV1LocationsCountriesResponse> countries();

  /// [country] - ISO country code or country id. Defaults to the first active country.
  @GET('/api/v1/locations/counties')
  Future<GetApiV1LocationsCountiesResponse> counties({
    @Query('country') String? country,
  });

  /// [q] - A place name from the device’s reverse lookup.
  @GET('/api/v1/locations/counties/match')
  Future<GetApiV1LocationsCountiesMatchResponse> match({
    @Query('q') required String q,
    @Query('country') String? country,
  });
}
