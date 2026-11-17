// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_viewer_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupViewerDto _$GroupViewerDtoFromJson(Map<String, dynamic> json) =>
    GroupViewerDto(
      joined: json['joined'] as bool,
      role: json['role'] == null
          ? null
          : GroupViewerDtoRole.fromJson(json['role'] as String),
      canPost: json['canPost'] as bool,
    );

Map<String, dynamic> _$GroupViewerDtoToJson(GroupViewerDto instance) =>
    <String, dynamic>{
      'joined': instance.joined,
      'role': instance.role,
      'canPost': instance.canPost,
    };
