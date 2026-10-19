// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateProfileDto _$UpdateProfileDtoFromJson(Map<String, dynamic> json) =>
    UpdateProfileDto(
      displayName: json['displayName'] as String?,
      headline: json['headline'] as String?,
      bio: json['bio'] as String?,
      links: (json['links'] as List<dynamic>?)
          ?.map((e) => ProfileLinkInputDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      openToCommissions: json['openToCommissions'] as bool?,
      contactShowEmail: json['contactShowEmail'] as bool?,
      contactShowPhone: json['contactShowPhone'] as bool?,
      contactForConnections: json['contactForConnections'] as bool?,
      acceptConnections: json['acceptConnections'] as bool?,
    );

Map<String, dynamic> _$UpdateProfileDtoToJson(UpdateProfileDto instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'headline': instance.headline,
      'bio': instance.bio,
      'links': instance.links,
      'openToCommissions': instance.openToCommissions,
      'contactShowEmail': instance.contactShowEmail,
      'contactShowPhone': instance.contactShowPhone,
      'contactForConnections': instance.contactForConnections,
      'acceptConnections': instance.acceptConnections,
    };
