// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_to_meet_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonToMeetDto _$PersonToMeetDtoFromJson(Map<String, dynamic> json) =>
    PersonToMeetDto(
      person: CreativeCardDto.fromJson(json['person'] as Map<String, dynamic>),
      connectionState: PersonConnectionState.fromJson(
        json['connectionState'] as String,
      ),
      connectionId: json['connectionId'] as String?,
    );

Map<String, dynamic> _$PersonToMeetDtoToJson(PersonToMeetDto instance) =>
    <String, dynamic>{
      'person': instance.person,
      'connectionState': instance.connectionState,
      'connectionId': instance.connectionId,
    };
