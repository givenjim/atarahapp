// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterResultDto _$RegisterResultDtoFromJson(Map<String, dynamic> json) =>
    RegisterResultDto(
      verification: VerificationSentDto.fromJson(
        json['verification'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$RegisterResultDtoToJson(RegisterResultDto instance) =>
    <String, dynamic>{'verification': instance.verification};
