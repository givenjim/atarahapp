// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_session_type_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateSessionTypeDto _$UpdateSessionTypeDtoFromJson(
  Map<String, dynamic> json,
) => UpdateSessionTypeDto(
  name: json['name'] as String?,
  description: json['description'],
  durationMinutes: json['durationMinutes'] as num?,
  priceMinor: json['priceMinor'] as num?,
  sessionCount: json['sessionCount'] as num?,
  active: json['active'] as bool?,
);

Map<String, dynamic> _$UpdateSessionTypeDtoToJson(
  UpdateSessionTypeDto instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'durationMinutes': instance.durationMinutes,
  'priceMinor': instance.priceMinor,
  'sessionCount': instance.sessionCount,
  'active': instance.active,
};
