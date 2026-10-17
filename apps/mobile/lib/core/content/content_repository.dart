import '../api/generated/export.dart';
import '../networking/failures.dart';

/// Content the app needs before anyone signs in: which optional features are on, and the legal text.
class ContentRepository {
  ContentRepository({required this._api});

  final AtarahApiClient _api;

  /// Feature switches from the server. Anything unknown or unreachable counts as off, so a feature never
  /// appears just because the request failed.
  Future<bool> googleSignInEnabled() async {
    try {
      return (await _api.public.config()).data.googleSignIn;
    } on Object {
      return false;
    }
  }

  Future<LegalDocumentDto> legalDocument(String type) async {
    try {
      return (await _api.public.legal(type: type)).data;
    } on Object catch (e) {
      throw mapError(e);
    }
  }
}
