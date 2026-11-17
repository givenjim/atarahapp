// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_change_started_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactChangeStartedDto _$ContactChangeStartedDtoFromJson(
  Map<String, dynamic> json,
) => ContactChangeStartedDto(
  kind: ContactChangeStartedDtoKind.fromJson(json['kind'] as String),
  sentTo: json['sentTo'] as String,
);

Map<String, dynamic> _$ContactChangeStartedDtoToJson(
  ContactChangeStartedDto instance,
) => <String, dynamic>{'kind': instance.kind, 'sentTo': instance.sentTo};
