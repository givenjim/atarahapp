import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/api/generated/export.dart';
import '../../core/providers.dart';
import 'cv_repository.dart';

part 'cv_providers.g.dart';

@Riverpod(keepAlive: true)
CvRepository cvRepository(Ref ref) =>
    CvRepository(api: ref.watch(apiClientProvider));

/// How long the PDF flow waits between checks of a build. Replaced with zero in tests.
@Riverpod(keepAlive: true)
Duration cvPollInterval(Ref ref) => const Duration(seconds: 2);

/// One format's choices, preview, latest PDF and share links, as the server filters them.
@riverpod
class CvDoc extends _$CvDoc {
  @override
  Future<CvStateDto> build(String format) =>
      ref.watch(cvRepositoryProvider).state(format);

  /// Saves the choices and keeps the answer (which carries the refreshed preview). Throws the typed failure.
  Future<void> save(UpdateCvDto body) async {
    final next = await ref.read(cvRepositoryProvider).update(format, body);
    state = AsyncData(next);
  }

  /// Re-reads everything (after a link is created or revoked, or a PDF finishes).
  Future<void> reload() async {
    final next = await ref.read(cvRepositoryProvider).state(format);
    state = AsyncData(next);
  }
}
