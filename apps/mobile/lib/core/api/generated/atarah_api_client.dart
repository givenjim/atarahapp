// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'auth/auth_client.dart';
import 'users/users_client.dart';
import 'admin_auth/admin_auth_client.dart';
import 'admin/admin_client.dart';
import 'media/media_client.dart';
import 'notifications/notifications_client.dart';
import 'public/public_client.dart';
import 'taxonomy/taxonomy_client.dart';
import 'locations/locations_client.dart';
import 'onboarding/onboarding_client.dart';
import 'admin_taxonomy/admin_taxonomy_client.dart';
import 'profile/profile_client.dart';
import 'portfolio/portfolio_client.dart';
import 'admin_portfolio/admin_portfolio_client.dart';
import 'articles/articles_client.dart';
import 'admin_content/admin_content_client.dart';
import 'discover/discover_client.dart';

/// Atarah API `v1.0`.
///
/// Atarah — Create · Connect · Grow. Versioned REST API (Luxaion Creatives).
class AtarahApiClient {
  AtarahApiClient(Dio dio, {String? baseUrl}) : _dio = dio, _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => '1.0';

  AuthClient? _auth;
  UsersClient? _users;
  AdminAuthClient? _adminAuth;
  AdminClient? _admin;
  MediaClient? _media;
  NotificationsClient? _notifications;
  PublicClient? _public;
  TaxonomyClient? _taxonomy;
  LocationsClient? _locations;
  OnboardingClient? _onboarding;
  AdminTaxonomyClient? _adminTaxonomy;
  ProfileClient? _profile;
  PortfolioClient? _portfolio;
  AdminPortfolioClient? _adminPortfolio;
  ArticlesClient? _articles;
  AdminContentClient? _adminContent;
  DiscoverClient? _discover;

  AuthClient get auth => _auth ??= AuthClient(_dio, baseUrl: _baseUrl);

  UsersClient get users => _users ??= UsersClient(_dio, baseUrl: _baseUrl);

  AdminAuthClient get adminAuth =>
      _adminAuth ??= AdminAuthClient(_dio, baseUrl: _baseUrl);

  AdminClient get admin => _admin ??= AdminClient(_dio, baseUrl: _baseUrl);

  MediaClient get media => _media ??= MediaClient(_dio, baseUrl: _baseUrl);

  NotificationsClient get notifications =>
      _notifications ??= NotificationsClient(_dio, baseUrl: _baseUrl);

  PublicClient get public => _public ??= PublicClient(_dio, baseUrl: _baseUrl);

  TaxonomyClient get taxonomy =>
      _taxonomy ??= TaxonomyClient(_dio, baseUrl: _baseUrl);

  LocationsClient get locations =>
      _locations ??= LocationsClient(_dio, baseUrl: _baseUrl);

  OnboardingClient get onboarding =>
      _onboarding ??= OnboardingClient(_dio, baseUrl: _baseUrl);

  AdminTaxonomyClient get adminTaxonomy =>
      _adminTaxonomy ??= AdminTaxonomyClient(_dio, baseUrl: _baseUrl);

  ProfileClient get profile =>
      _profile ??= ProfileClient(_dio, baseUrl: _baseUrl);

  PortfolioClient get portfolio =>
      _portfolio ??= PortfolioClient(_dio, baseUrl: _baseUrl);

  AdminPortfolioClient get adminPortfolio =>
      _adminPortfolio ??= AdminPortfolioClient(_dio, baseUrl: _baseUrl);

  ArticlesClient get articles =>
      _articles ??= ArticlesClient(_dio, baseUrl: _baseUrl);

  AdminContentClient get adminContent =>
      _adminContent ??= AdminContentClient(_dio, baseUrl: _baseUrl);

  DiscoverClient get discover =>
      _discover ??= DiscoverClient(_dio, baseUrl: _baseUrl);
}
