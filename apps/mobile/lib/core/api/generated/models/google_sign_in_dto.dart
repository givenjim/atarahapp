// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'google_sign_in_dto_client.dart';

part 'google_sign_in_dto.g.dart';

@JsonSerializable()
class GoogleSignInDto {
  const GoogleSignInDto({required this.idToken, required this.client});

  factory GoogleSignInDto.fromJson(Map<String, Object?> json) =>
      _$GoogleSignInDtoFromJson(json);

  final String idToken;
  final GoogleSignInDtoClient client;

  Map<String, Object?> toJson() => _$GoogleSignInDtoToJson(this);
}
