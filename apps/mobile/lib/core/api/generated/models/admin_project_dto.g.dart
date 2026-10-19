// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_project_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminProjectDto _$AdminProjectDtoFromJson(Map<String, dynamic> json) =>
    AdminProjectDto(
      id: json['id'] as String,
      title: json['title'] as String,
      category: AdminProjectDtoCategory.fromJson(json['category'] as String),
      featured: json['featured'] as bool,
      status: AdminProjectDtoStatus.fromJson(json['status'] as String),
      visibility: AdminProjectDtoVisibility.fromJson(
        json['visibility'] as String,
      ),
      mediaCount: json['mediaCount'] as num,
      hidden: json['hidden'] as bool,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      ownerUserId: json['ownerUserId'] as String,
      ownerName: json['ownerName'] as String,
      role: json['role'] as String?,
      projectDate: json['projectDate'] as String?,
      coverUrl: json['coverUrl'] as String?,
      ownerHandle: json['ownerHandle'] as String?,
      hiddenReason: json['hiddenReason'] as String?,
      hiddenAt: json['hiddenAt'] == null
          ? null
          : DateTime.parse(json['hiddenAt'] as String),
    );

Map<String, dynamic> _$AdminProjectDtoToJson(AdminProjectDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'role': instance.role,
      'category': instance.category,
      'projectDate': instance.projectDate,
      'featured': instance.featured,
      'status': instance.status,
      'visibility': instance.visibility,
      'coverUrl': instance.coverUrl,
      'mediaCount': instance.mediaCount,
      'hidden': instance.hidden,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'ownerUserId': instance.ownerUserId,
      'ownerName': instance.ownerName,
      'ownerHandle': instance.ownerHandle,
      'hiddenReason': instance.hiddenReason,
      'hiddenAt': instance.hiddenAt?.toIso8601String(),
    };
