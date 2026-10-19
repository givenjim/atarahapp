// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'profile_link_input_dto.dart';

part 'update_profile_dto.g.dart';

@JsonSerializable()
class UpdateProfileDto {
  const UpdateProfileDto({
    this.displayName,
    this.headline,
    this.bio,
    this.links,
    this.openToCommissions,
    this.contactShowEmail,
    this.contactShowPhone,
    this.contactForConnections,
    this.acceptConnections,
  });

  factory UpdateProfileDto.fromJson(Map<String, Object?> json) =>
      _$UpdateProfileDtoFromJson(json);

  final String? displayName;

  /// Send an empty string to clear it.
  final String? headline;

  /// Send an empty string to clear it.
  final String? bio;

  /// Replaces all links. At most 8.
  final List<ProfileLinkInputDto>? links;
  final bool? openToCommissions;

  /// Show the email when the contact section is visible.
  final bool? contactShowEmail;

  /// Show the phone number when the contact section is visible.
  final bool? contactShowPhone;

  /// Accepted connections see contact details even when the section is private.
  final bool? contactForConnections;

  /// When false nobody can send a connection request.
  final bool? acceptConnections;

  Map<String, Object?> toJson() => _$UpdateProfileDtoToJson(this);
}
