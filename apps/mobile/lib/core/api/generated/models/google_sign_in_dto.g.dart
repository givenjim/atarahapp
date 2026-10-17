// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_sign_in_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleSignInDto _$GoogleSignInDtoFromJson(Map<String, dynamic> json) =>
    GoogleSignInDto(
      idToken: json['idToken'] as String,
      client: GoogleSignInDtoClient.fromJson(json['client'] as String),
    );

Map<String, dynamic> _$GoogleSignInDtoToJson(GoogleSignInDto instance) =>
    <String, dynamic>{'idToken': instance.idToken, 'client': instance.client};
