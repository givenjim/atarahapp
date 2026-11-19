import '../../core/api/generated/export.dart';
import '../../core/networking/failures.dart';

/// The four document formats, in the order of the format picker. The API names are the values.
const cvFormats = ['CV', 'BIO', 'EPK', 'DECK'];

/// The Creative CV / EPK endpoints with errors mapped to typed failures. Widgets go through providers; tests replace this
/// with an in-memory fake.
class CvRepository {
  CvRepository({required this._api});

  final AtarahApiClient _api;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Object catch (e) {
      throw mapError(e);
    }
  }

  Future<CvStateDto> state(String format) =>
      _guard(() async => (await _api.creativeCv.state(format: format)).data);

  Future<CvStateDto> update(String format, UpdateCvDto body) => _guard(
    () async => (await _api.creativeCv.update(format: format, body: body)).data,
  );

  /// Queues a PDF build. Poll [renderStatus] until it is READY or FAILED.
  Future<CvRenderDto> generate(String format) =>
      _guard(() async => (await _api.creativeCv.generate(format: format)).data);

  Future<CvRenderDto> renderStatus(String id) =>
      _guard(() async => (await _api.creativeCv.renderStatus(id: id)).data);

  /// A short-lived signed link to the finished PDF.
  Future<CvDownloadDto> download(String id) =>
      _guard(() async => (await _api.creativeCv.download(id: id)).data);

  /// Creates a public link. The full address is in this answer only.
  Future<CvShareCreatedDto> createShare(String format, {int? expiresInDays}) =>
      _guard(
        () async => (await _api.creativeCv.createShare(
          format: format,
          body: CreateShareDto(expiresInDays: expiresInDays),
        )).data,
      );

  Future<CvShareDto> revokeShare(String id) =>
      _guard(() async => (await _api.creativeCv.revokeShare(id: id)).data);
}
