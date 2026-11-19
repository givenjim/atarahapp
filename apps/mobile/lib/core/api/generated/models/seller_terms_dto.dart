// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'seller_terms_dto.g.dart';

@JsonSerializable()
class SellerTermsDto {
  const SellerTermsDto({
    required this.version,
    required this.isDraft,
    required this.title,
    required this.body,
  });
  
  factory SellerTermsDto.fromJson(Map<String, Object?> json) => _$SellerTermsDtoFromJson(json);
  
  final String version;

  /// True while the text is the placeholder, not the owner-approved terms.
  final bool isDraft;
  final String title;
  final String body;

  Map<String, Object?> toJson() => _$SellerTermsDtoToJson(this);
}
