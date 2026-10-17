// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'upload_ticket_dto_method.dart';

part 'upload_ticket_dto.g.dart';

@JsonSerializable()
class UploadTicketDto {
  const UploadTicketDto({
    required this.id,
    required this.uploadUrl,
    required this.method,
    required this.headers,
    required this.expiresAt,
  });

  factory UploadTicketDto.fromJson(Map<String, Object?> json) =>
      _$UploadTicketDtoFromJson(json);

  final String id;

  /// Signed URL. PUT the file bytes here with the headers below.
  final String uploadUrl;
  final UploadTicketDtoMethod method;
  final Map<String, String> headers;
  final DateTime expiresAt;

  Map<String, Object?> toJson() => _$UploadTicketDtoToJson(this);
}
