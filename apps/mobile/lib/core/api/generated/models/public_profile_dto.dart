// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'connection_state_dto.dart';
import 'contact_details_dto.dart';
import 'discipline_lite.dart';
import 'location_dto.dart';
import 'profile_link_dto.dart';
import 'public_profile_dto_locked_sections.dart';
import 'public_profile_dto_relation.dart';
import 'public_profile_dto_visible_sections.dart';
import 'taxonomy_item_dto.dart';

part 'public_profile_dto.g.dart';

@JsonSerializable()
class PublicProfileDto {
  const PublicProfileDto({
    required this.handle,
    required this.displayName,
    required this.avatarUrl,
    required this.headline,
    required this.discipline,
    required this.specialisations,
    required this.openToCommissions,
    required this.memberSince,
    required this.relation,
    required this.connection,
    required this.bio,
    required this.location,
    required this.skills,
    required this.links,
    required this.contact,
    required this.visibleSections,
    required this.lockedSections,
    required this.connectionCount,
    required this.shareUrl,
    this.portfolioCount,
    this.serviceCount,
  });

  factory PublicProfileDto.fromJson(Map<String, Object?> json) =>
      _$PublicProfileDtoFromJson(json);

  final String handle;
  final String displayName;
  final String? avatarUrl;
  final String? headline;
  final DisciplineLite? discipline;
  final List<TaxonomyItemDto> specialisations;
  final bool openToCommissions;
  final DateTime memberSince;

  /// How the caller relates to this profile (or the preview they asked for).
  final PublicProfileDtoRelation relation;

  /// Null for the owner, in a preview and when signed out.
  final ConnectionStateDto? connection;
  final String? bio;
  final LocationDto? location;
  final List<TaxonomyItemDto>? skills;
  final List<ProfileLinkDto>? links;
  final ContactDetailsDto? contact;

  /// Projects this viewer can open. Null while the Portfolio section is hidden from them.
  final num? portfolioCount;

  /// Null while the Services section is hidden from this viewer.
  final num? serviceCount;

  /// Sections the caller may see (some have no content yet).
  final List<PublicProfileDtoVisibleSections> visibleSections;

  /// Sections hidden from the caller.
  final List<PublicProfileDtoLockedSections> lockedSections;

  /// Accepted connections; members only.
  final num? connectionCount;
  final String shareUrl;

  Map<String, Object?> toJson() => _$PublicProfileDtoToJson(this);
}
