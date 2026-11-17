// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publish_legal_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublishLegalDto _$PublishLegalDtoFromJson(Map<String, dynamic> json) =>
    PublishLegalDto(
      effectiveAt: json['effectiveAt'] == null
          ? null
          : DateTime.parse(json['effectiveAt'] as String),
    );

Map<String, dynamic> _$PublishLegalDtoToJson(PublishLegalDto instance) =>
    <String, dynamic>{'effectiveAt': instance.effectiveAt?.toIso8601String()};
