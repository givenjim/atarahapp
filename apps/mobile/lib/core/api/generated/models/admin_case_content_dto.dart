// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_case_content_dto_status.dart';

part 'admin_case_content_dto.g.dart';

@JsonSerializable()
class AdminCaseContentDto {
  const AdminCaseContentDto({
    required this.exists,
    required this.status,
    required this.text,
    required this.postId,
    required this.createdAt,
  });
  
  factory AdminCaseContentDto.fromJson(Map<String, Object?> json) => _$AdminCaseContentDtoFromJson(json);
  
  /// False when the content has been deleted by its author.
  final bool exists;
  final AdminCaseContentDtoStatus? status;

  /// The post or comment text, the account name, or the group name.
  final String? text;

  /// The post a comment belongs to.
  final String? postId;
  final DateTime? createdAt;

  Map<String, Object?> toJson() => _$AdminCaseContentDtoToJson(this);
}
