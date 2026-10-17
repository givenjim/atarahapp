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

  AuthClient get auth => _auth ??= AuthClient(_dio, baseUrl: _baseUrl);

  UsersClient get users => _users ??= UsersClient(_dio, baseUrl: _baseUrl);

  AdminAuthClient get adminAuth =>
      _adminAuth ??= AdminAuthClient(_dio, baseUrl: _baseUrl);

  AdminClient get admin => _admin ??= AdminClient(_dio, baseUrl: _baseUrl);

  MediaClient get media => _media ??= MediaClient(_dio, baseUrl: _baseUrl);

  NotificationsClient get notifications =>
      _notifications ??= NotificationsClient(_dio, baseUrl: _baseUrl);
}
