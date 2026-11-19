// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'creative_card_dto.dart';
import 'person_connection_state.dart';

part 'person_to_meet_dto.g.dart';

@JsonSerializable()
class PersonToMeetDto {
  const PersonToMeetDto({
    required this.person,
    required this.connectionState,
    required this.connectionId,
  });
  
  factory PersonToMeetDto.fromJson(Map<String, Object?> json) => _$PersonToMeetDtoFromJson(json);
  
  /// `person.reason` is the line shown under the name.
  final CreativeCardDto person;

  /// PENDING_SENT shows "Requested".
  final PersonConnectionState connectionState;

  /// Use it to cancel a sent request.
  final String? connectionId;

  Map<String, Object?> toJson() => _$PersonToMeetDtoToJson(this);
}
