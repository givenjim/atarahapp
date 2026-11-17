// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'import_csv_dto.g.dart';

@JsonSerializable()
class ImportCsvDto {
  const ImportCsvDto({required this.csv});

  factory ImportCsvDto.fromJson(Map<String, Object?> json) =>
      _$ImportCsvDtoFromJson(json);

  /// The whole CSV file as text (UTF-8).
  final String csv;

  Map<String, Object?> toJson() => _$ImportCsvDtoToJson(this);
}
