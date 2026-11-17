import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../account/account_common.dart';
import '../account/account_providers.dart';
import '../discover/discover_common.dart';

/// Account: name and username to edit, and email and phone with their verified badges and a change flow each (the
/// new contact is confirmed before it replaces the old one, and the old one is told).
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _name = TextEditingController();
  final _handle = TextEditingController();
  AccountDto? _loaded;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _handle.dispose();
    super.dispose();
  }

  void _adopt(AccountDto a) {
    if (_loaded != null) return;
    _loaded = a;
    _name.text = a.fullName;
    _handle.text = a.handle ?? '';
  }

  bool get _dirty =>
      _loaded != null &&
      (_name.text.trim() != _loaded!.fullName ||
          _handle.text.trim() != (_loaded!.handle ?? ''));

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final base = _loaded!;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final next = await ref
          .read(accountRepositoryProvider)
          .updateAccount(
            fullName: _name.text.trim() == base.fullName
                ? null
                : _name.text.trim(),
            handle: _handle.text.trim() == (base.handle ?? '')
                ? null
                : _handle.text.trim(),
          );
      _loaded = next;
      ref.invalidate(accountProvider);
      if (mounted) showNotice(context, l10n.stSaved);
    } on Object catch (e) {
      _error = failureMessage(e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _change(AccountDto a, ContactChangeStartedDtoKind kind) async {
    await showAtBottomSheet<void>(
      context: context,
      title: kind == ContactChangeStartedDtoKind.email
          ? AppLocalizations.of(context).stChangeEmail
          : AppLocalizations.of(context).stChangePhone,
      builder: (_) => _ChangeContactSheet(kind: kind),
    );
    ref.invalidate(accountProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(accountProvider);
    return SubPage(
      title: l10n.settingsAccount,
      child: async.when(
        skipLoadingOnReload: true,
        loading: () => const AtLoadingBody(),
        error: (e, _) =>
            loadFailure(e, () => ref.invalidate(accountProvider), l10n),
        data: (a) {
          _adopt(a);
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AtSpacing.gutter,
              8,
              AtSpacing.gutter,
              32,
            ),
            children: [
              AtTextField(
                label: l10n.stFullName,
                controller: _name,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              AtTextField(
                label: l10n.stUsername,
                controller: _handle,
                prefixText: '@',
                helperText: l10n.stUsernameHelp,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              _ContactRow(
                label: l10n.stEmail,
                value: a.email ?? l10n.stNotSet,
                verified: a.email != null && a.emailVerified,
                pending: a.pendingEmail,
                onChange: () => _change(a, ContactChangeStartedDtoKind.email),
              ),
              const SizedBox(height: 14),
              _ContactRow(
                label: l10n.stPhone,
                value: a.phone ?? l10n.stNotSet,
                verified: a.phone != null && a.phoneVerified,
                pending: a.pendingPhone,
                onChange: () => _change(a, ContactChangeStartedDtoKind.phone),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                AtInlineBanner(message: _error!, tone: AtBannerTone.error),
              ],
              const SizedBox(height: 24),
              AtButton(
                label: l10n.stSaveChanges,
                loading: _saving,
                onPressed: _dirty && !_saving ? _save : null,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.label,
    required this.value,
    required this.verified,
    required this.onChange,
    this.pending,
  });

  final String label;
  final String value;
  final bool verified;
  final String? pending;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AtTextStyles.label.copyWith(color: context.at.ink)),
        const SizedBox(height: 7),
        Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: context.at.inputFill,
            borderRadius: AtRadii.input,
            border: Border.all(color: context.at.inputBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AtTextStyles.body.copyWith(color: context.at.ink),
                ),
              ),
              if (verified) ...[
                const AtVerifiedTick(size: 16),
                const SizedBox(width: 4),
                Text(
                  l10n.verified,
                  style: AtTextStyles.metaSm.copyWith(
                    color: context.at.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              AtButton(
                label: l10n.stChange,
                variant: AtButtonVariant.tertiary,
                size: AtButtonSize.sm,
                fullWidth: false,
                onPressed: onChange,
              ),
            ],
          ),
        ),
        if (pending != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Icon(LucideIcons.clock, size: 14, color: context.at.muted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.stPendingChange(pending!),
                    style: AtTextStyles.metaSm.copyWith(
                      color: context.at.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Change email (a link is sent to confirm) or phone (a code is sent, then entered here).
class _ChangeContactSheet extends ConsumerStatefulWidget {
  const _ChangeContactSheet({required this.kind});

  final ContactChangeStartedDtoKind kind;

  @override
  ConsumerState<_ChangeContactSheet> createState() =>
      _ChangeContactSheetState();
}

class _ChangeContactSheetState extends ConsumerState<_ChangeContactSheet> {
  final _value = TextEditingController();
  final _code = TextEditingController();
  bool _busy = false;
  String? _error;
  String? _sentTo;

  bool get _email => widget.kind == ContactChangeStartedDtoKind.email;

  @override
  void dispose() {
    _value.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = ref.read(accountRepositoryProvider);
      final started = _email
          ? await repo.changeEmail(_value.text.trim())
          : await repo.changePhone(_value.text.trim());
      setState(() => _sentTo = started.sentTo);
    } on Object catch (e) {
      setState(() => _error = failureMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(accountRepositoryProvider)
          .verifyPhone(_value.text.trim(), _code.text.trim());
      if (mounted) Navigator.of(context).pop();
    } on Object catch (e) {
      setState(() => _error = failureMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sent = _sentTo != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!sent) ...[
            Text(
              _email ? l10n.stChangeEmailBody : l10n.stChangePhoneBody,
              style: AtTextStyles.bodySm.copyWith(color: context.at.body),
            ),
            const SizedBox(height: 14),
            AtTextField(
              label: _email ? l10n.stNewEmail : l10n.stNewPhone,
              controller: _value,
              keyboardType: _email
                  ? TextInputType.emailAddress
                  : TextInputType.phone,
              hint: _email ? 'name@example.com' : '+254 7XX XXX XXX',
              onChanged: (_) => setState(() {}),
            ),
          ] else if (_email) ...[
            AtInlineBanner(
              message: l10n.stEmailLinkSent(_sentTo!),
              tone: AtBannerTone.success,
            ),
          ] else ...[
            Text(
              l10n.stPhoneCodeSent(_sentTo!),
              style: AtTextStyles.bodySm.copyWith(color: context.at.body),
            ),
            const SizedBox(height: 14),
            AtCodeInput(controller: _code, onChanged: (_) => setState(() {})),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            AtInlineBanner(message: _error!, tone: AtBannerTone.error),
          ],
          const SizedBox(height: 18),
          if (!sent)
            AtButton(
              label: _email ? l10n.stSendLink : l10n.stSendCode,
              loading: _busy,
              onPressed: _value.text.trim().isEmpty || _busy ? null : _send,
            )
          else if (_email)
            AtButton(
              label: l10n.stDone,
              onPressed: () => Navigator.of(context).pop(),
            )
          else
            AtButton(
              label: l10n.stVerify,
              loading: _busy,
              onPressed: _code.text.trim().length < 4 || _busy ? null : _verify,
            ),
        ],
      ),
    );
  }
}
