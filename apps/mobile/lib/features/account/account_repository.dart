import '../../core/api/generated/export.dart';
import '../../core/networking/failures.dart';

int _total(dynamic meta, int fallback) {
  if (meta is Map && meta['total'] is num) {
    return (meta['total'] as num).toInt();
  }
  return fallback;
}

/// One page of an offset-paged list.
class PageOf<T> {
  const PageOf(this.items, this.total);

  final List<T> items;
  final int total;

  bool get hasMore => items.length < total;
}

/// Runs a call and turns any error into the app's typed failures.
Future<T> guarded<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on Object catch (e) {
    throw mapError(e);
  }
}

// ---- activity -------------------------------------------------------------------------------------------------

/// "Pick up where you left off", the hub counts and the member's applications.
class ActivityRepository {
  ActivityRepository({required this._api});

  final AtarahApiClient _api;

  Future<ActivityDto> hub() =>
      guarded(() async => (await _api.activity.hub()).data);

  Future<PageOf<ApplicationItemDto>> applications({
    int page = 1,
    int limit = 20,
  }) => guarded(() async {
    final res = await _api.activity.applications(page: page, limit: limit);
    return PageOf(res.data, _total(res.meta, res.data.length));
  });
}

// ---- notifications --------------------------------------------------------------------------------------------

class NotificationsRepository {
  NotificationsRepository({required this._api, required this._readAllUntyped});

  final AtarahApiClient _api;

  /// `POST /notifications/read-all` with no category (the generated client insists on one).
  final Future<void> Function() _readAllUntyped;

  Future<PageOf<NotificationItemDto>> list({
    NotificationCategory? category,
    int page = 1,
    int limit = 20,
  }) => guarded(() async {
    final res = await _api.notifications.list(
      category: category,
      page: page,
      limit: limit,
    );
    return PageOf(res.data, _total(res.meta, res.data.length));
  });

  Future<UnreadCountDto> unreadCount() =>
      guarded(() async => (await _api.notifications.unreadCount()).data);

  Future<void> markRead(String id) =>
      guarded(() => _api.notifications.markRead(id: id));

  /// Marks everything read, or only [category] when given.
  Future<void> readAll({NotificationCategory? category}) => guarded(() async {
    if (category == null) {
      await _readAllUntyped();
    } else {
      await _api.notifications.readAll(
        body: MarkAllReadDto(category: category),
      );
    }
  });

  Future<List<PreferenceDto>> preferences() => guarded(
    () async => (await _api.notifications.preferences()).data.preferences,
  );

  Future<List<PreferenceDto>> updatePreferences(List<PreferenceDto> next) =>
      guarded(
        () async => (await _api.notifications.updatePreferences(
          body: UpdatePreferencesDto(preferences: next),
        )).data.preferences,
      );
}

// ---- saved ----------------------------------------------------------------------------------------------------

/// Every save button in the app goes through here (the saved routes are one set for all types).
class SavedRepository {
  SavedRepository({required this._api});

  final AtarahApiClient _api;

  Future<PageOf<SavedItemDto>> list({
    SavedKind? type,
    int page = 1,
    int limit = 20,
  }) => guarded(() async {
    final res = await _api.saved.list(type: type, page: page, limit: limit);
    return PageOf(res.data, _total(res.meta, res.data.length));
  });

  Future<SavedCountsDto> counts() =>
      guarded(() async => (await _api.saved.counts()).data);

  Future<void> save(SavedKind type, String id) => guarded(
    () => _api.saved.save(
      type: Type2.fromJson(type.json!),
      id: id,
      body: const SaveBodyDto(),
    ),
  );

  Future<void> unsave(SavedKind type, String id) => guarded(
    () => _api.saved.unsave(type: Type2.fromJson(type.json!), id: id),
  );
}

// ---- account and settings -------------------------------------------------------------------------------------

/// Account details, privacy, security, export, deletion and membership.
class AccountRepository {
  AccountRepository({required this._api});

  final AtarahApiClient _api;

  Future<AccountDto> account() =>
      guarded(() async => (await _api.account.getAccount()).data);

  Future<AccountDto> updateAccount({String? fullName, String? handle}) =>
      guarded(
        () async => (await _api.account.updateAccount(
          body: UpdateAccountDto(fullName: fullName, handle: handle),
        )).data,
      );

  /// Starts an email change: the address gets a link to confirm.
  Future<ContactChangeStartedDto> changeEmail(String email) => guarded(
    () async =>
        (await _api.account.changeEmail(body: ChangeEmailDto(email: email)))
            .data,
  );

  /// Starts a phone change: a code is sent to the new number.
  Future<ContactChangeStartedDto> changePhone(String phone) => guarded(
    () async =>
        (await _api.account.changePhone(body: ChangePhoneDto(phone: phone)))
            .data,
  );

  Future<void> verifyPhone(String phone, String code) => guarded(
    () => _api.account.verifyPhone(
      body: VerifyPhoneChangeDto(phone: phone, code: code),
    ),
  );

  Future<void> changePassword(String current, String next) => guarded(
    () => _api.account.changePassword(
      body: ChangePasswordDto(currentPassword: current, newPassword: next),
    ),
  );

  Future<PrivacyDto> privacy() =>
      guarded(() async => (await _api.account.getPrivacy()).data);

  Future<PrivacyDto> setPrivacy(PrivacyField field, Visibility visibility) =>
      guarded(
        () async => (await _api.account.updatePrivacy(
          body: UpdatePrivacyDto(field: field, visibility: visibility),
        )).data,
      );

  Future<SecurityDto> security() =>
      guarded(() async => (await _api.users.securityOverview()).data);

  Future<List<SessionViewDto>> sessions() =>
      guarded(() async => (await _api.auth.list()).data);

  Future<void> revokeSession(String id) =>
      guarded(() => _api.auth.revoke(id: id));

  Future<TwoStepDto> setTwoStep(bool enabled) => guarded(
    () async =>
        (await _api.account.setTwoStep(body: SetTwoStepDto(enabled: enabled)))
            .data,
  );

  Future<ExportStateDto> exportState() =>
      guarded(() async => (await _api.account.exportState()).data);

  Future<ExportStateDto> requestExport() =>
      guarded(() async => (await _api.account.requestExport()).data);

  /// [confirm] must be the word DELETE. [password] is sent when the member re-authenticates with it.
  Future<void> deleteAccount({required String confirm, String? password}) =>
      guarded(
        () => _api.account.deleteAccount(
          body: DeleteAccountDto(confirm: confirm, password: password),
        ),
      );

  Future<void> restore() => guarded(() => _api.account.restore());

  Future<MembershipViewDto> membership() =>
      guarded(() async => (await _api.account.getMembership()).data);
}

// ---- help and legal -------------------------------------------------------------------------------------------

class HelpRepository {
  HelpRepository({required this._api});

  final AtarahApiClient _api;

  Future<HelpResultDto> search([String? q]) => guarded(
    () async =>
        (await _api.help.search(q: (q ?? '').trim().isEmpty ? null : q!.trim()))
            .data,
  );

  Future<HelpArticleDto> article(String slug) =>
      guarded(() async => (await _api.help.article(slug: slug)).data);

  Future<HelpContactDto> contact() =>
      guarded(() async => (await _api.help.contact()).data);

  Future<List<LegalSummaryDto>> legalList() =>
      guarded(() async => (await _api.help.legalList()).data);

  Future<LegalFullDto> legalDocument(String type) =>
      guarded(() async => (await _api.help.legalDocument(type: type)).data);
}
