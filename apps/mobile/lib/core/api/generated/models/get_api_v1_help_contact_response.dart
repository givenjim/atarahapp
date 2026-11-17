// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'help_contact_dto.dart';

part 'get_api_v1_help_contact_response.g.dart';

@JsonSerializable()
class GetApiV1HelpContactResponse {
  const GetApiV1HelpContactResponse({required this.data, this.meta});

  factory GetApiV1HelpContactResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1HelpContactResponseFromJson(json);

  final HelpContactDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1HelpContactResponseToJson(this);
}
