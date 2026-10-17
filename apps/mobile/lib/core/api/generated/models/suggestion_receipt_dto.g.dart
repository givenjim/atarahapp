// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggestion_receipt_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SuggestionReceiptDto _$SuggestionReceiptDtoFromJson(
  Map<String, dynamic> json,
) => SuggestionReceiptDto(
  id: json['id'] as String,
  name: json['name'] as String,
  status: SuggestionReceiptDtoStatus.fromJson(json['status'] as String),
);

Map<String, dynamic> _$SuggestionReceiptDtoToJson(
  SuggestionReceiptDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'status': instance.status,
};
