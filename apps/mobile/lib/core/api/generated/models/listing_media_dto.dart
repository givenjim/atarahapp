// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'listing_media_dto_kind.dart';

part 'listing_media_dto.g.dart';

@JsonSerializable()
class ListingMediaDto {
  const ListingMediaDto({
    required this.id,
    required this.kind,
    this.url,
  });
  
  factory ListingMediaDto.fromJson(Map<String, Object?> json) => _$ListingMediaDtoFromJson(json);
  
  final String id;
  final ListingMediaDtoKind kind;
  final String? url;

  Map<String, Object?> toJson() => _$ListingMediaDtoToJson(this);
}
