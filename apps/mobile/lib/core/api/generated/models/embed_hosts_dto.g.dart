// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embed_hosts_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmbedHostsDto _$EmbedHostsDtoFromJson(Map<String, dynamic> json) =>
    EmbedHostsDto(
      hosts: (json['hosts'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$EmbedHostsDtoToJson(EmbedHostsDto instance) =>
    <String, dynamic>{'hosts': instance.hosts};
