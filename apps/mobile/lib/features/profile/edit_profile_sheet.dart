import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import 'profile_providers.dart';

const _maxLinks = 8;
final _https = RegExp(r'^https://[^\s/]+\.[^\s/]+', caseSensitive: false);

/// Opens the edit sheet. Resolves to true when the member saved.
Future<bool?> showEditProfileSheet(
  BuildContext context,
  OwnProfileDto profile,
) {
  return showAtBottomSheet<bool>(
    context: context,
    title: AppLocalizations.of(context).epTitle,
    builder: (_) => EditProfileSheet(profile: profile),
  );
}

class _LinkRow {
  _LinkRow(String label, String url)
    : label = TextEditingController(text: label),
      url = TextEditingController(text: url);

  final TextEditingController label;
  final TextEditingController url;
  String? labelError;
  String? urlError;

  void dispose() {
    label.dispose();
    url.dispose();
  }
}

/// Name, headline, bio, links and contact preferences. Checked on the device first; the server checks again
/// and its messages land under the matching field.
class EditProfileSheet extends ConsumerStatefulWidget {
  const EditProfileSheet({super.key, required this.profile});

  final OwnProfileDto profile;

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late final _name = TextEditingController(text: widget.profile.displayName);
  late final _headline = TextEditingController(
    text: widget.profile.headline ?? '',
  );
  late final _bio = TextEditingController(text: widget.profile.bio ?? '');
  late final List<_LinkRow> _links = [
    for (final l in widget.profile.links) _LinkRow(l.label, l.url),
  ];
  late bool _commissions = widget.profile.openToCommissions;
  late bool _showEmail = widget.profile.contact.showEmail;
  late bool _showPhone = widget.profile.contact.showPhone;
  late bool _forConnections = widget.profile.contact.forConnections;
  late bool _accept = widget.profile.acceptConnections;

  bool _busy = false;
  String? _nameError;
  String? _headlineError;
  String? _bioError;
  String? _banner;

  @override
  void dispose() {
    _name.dispose();
    _headline.dispose();
    _bio.dispose();
    for (final l in _links) {
      l.dispose();
    }
    super.dispose();
  }

  bool _validate(AppLocalizations l10n) {
    var ok = true;
    _nameError = _name.text.trim().length >= 2 ? null : l10n.epNameError;
    if (_nameError != null) ok = false;
    for (final l in _links) {
      l.labelError = l.label.text.trim().isEmpty
          ? l10n.epLinkLabelMissing
          : null;
      l.urlError = _https.hasMatch(l.url.text.trim())
          ? null
          : l10n.epLinkInvalid;
      if (l.labelError != null || l.urlError != null) ok = false;
    }
    setState(() => _banner = null);
    return ok;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (!_validate(l10n)) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(myProfileProvider.notifier)
          .save(
            UpdateProfileDto(
              displayName: _name.text.trim(),
              headline: _headline.text.trim(),
              bio: _bio.text.trim(),
              links: [
                for (final l in _links)
                  ProfileLinkInputDto(
                    label: l.label.text.trim(),
                    url: l.url.text.trim(),
                  ),
              ],
              openToCommissions: _commissions,
              contactShowEmail: _showEmail,
              contactShowPhone: _showPhone,
              contactForConnections: _forConnections,
              acceptConnections: _accept,
            ),
          );
      if (mounted) Navigator.of(context).pop(true);
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() {
        final field = e.details['field'];
        _nameError = field == 'displayName' ? e.message : null;
        _headlineError = field == 'headline' ? e.message : null;
        _bioError = field == 'bio' ? e.message : null;
        _banner = ['displayName', 'headline', 'bio'].contains(field)
            ? null
            : e.message;
      });
    } on AppFailure catch (e) {
      if (mounted) setState(() => _banner = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final height = MediaQuery.sizeOf(context).height * 0.85;
    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                AtSpacing.gutter,
                4,
                AtSpacing.gutter,
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AtTextField(
                    label: l10n.epDisplayName,
                    controller: _name,
                    maxLength: 60,
                    errorText: _nameError,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() => _nameError = null),
                  ),
                  const SizedBox(height: 14),
                  AtTextField(
                    label: l10n.epHeadline,
                    hint: l10n.epHeadlineHint,
                    controller: _headline,
                    maxLength: 80,
                    errorText: _headlineError,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() => _headlineError = null),
                  ),
                  const SizedBox(height: 14),
                  AtTextField(
                    label: l10n.epBio,
                    controller: _bio,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 160,
                    showCounter: true,
                    errorText: _bioError,
                    onChanged: (_) => setState(() => _bioError = null),
                  ),
                  const SizedBox(height: 22),
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.epLinks,
                      style: AtTextStyles.cardTitle.copyWith(
                        color: AtColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < _links.length; i++) ...[
                    _LinkEditor(
                      key: ObjectKey(_links[i]),
                      row: _links[i],
                      onRemove: () {
                        final gone = _links[i];
                        setState(() => _links.removeAt(i));
                        // The row's fields are still in this frame's tree; free them after it is drawn.
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => gone.dispose(),
                        );
                      },
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_links.length < _maxLinks)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AtButton(
                        label: l10n.epAddLink,
                        variant: AtButtonVariant.tertiary,
                        size: AtButtonSize.sm,
                        fullWidth: false,
                        icon: LucideIcons.plus,
                        onPressed: () =>
                            setState(() => _links.add(_LinkRow('', ''))),
                      ),
                    )
                  else
                    Text(
                      l10n.epLinksLimit(_maxLinks),
                      style: AtTextStyles.meta.copyWith(color: AtColors.muted),
                    ),
                  const SizedBox(height: 22),
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.epContactPrefs,
                      style: AtTextStyles.cardTitle.copyWith(
                        color: AtColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _ToggleRow(
                    label: l10n.epOpenToCommissions,
                    value: _commissions,
                    onChanged: (v) => setState(() => _commissions = v),
                  ),
                  _ToggleRow(
                    label: l10n.epAcceptConnections,
                    value: _accept,
                    onChanged: (v) => setState(() => _accept = v),
                  ),
                  _ToggleRow(
                    label: l10n.epShowEmail,
                    value: _showEmail,
                    onChanged: (v) => setState(() => _showEmail = v),
                  ),
                  _ToggleRow(
                    label: l10n.epShowPhone,
                    value: _showPhone,
                    onChanged: (v) => setState(() => _showPhone = v),
                  ),
                  _ToggleRow(
                    label: l10n.epContactForConnections,
                    value: _forConnections,
                    onChanged: (v) => setState(() => _forConnections = v),
                  ),
                  if (_banner != null) ...[
                    const SizedBox(height: 12),
                    AtInlineBanner(message: _banner!),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AtSpacing.gutter,
              8,
              AtSpacing.gutter,
              12,
            ),
            child: AtButton(
              label: l10n.epSave,
              loading: _busy,
              onPressed: _busy ? null : _save,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: label,
      excludeSemantics: true,
      onTap: () => onChanged(!value),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AtTextStyles.bodySm.copyWith(color: AtColors.ink),
                ),
              ),
              const SizedBox(width: 12),
              IgnorePointer(
                child: AtToggle(
                  value: value,
                  onChanged: onChanged,
                  semanticLabel: label,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkEditor extends StatelessWidget {
  const _LinkEditor({
    super.key,
    required this.row,
    required this.onRemove,
    required this.onChanged,
  });

  final _LinkRow row;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: AtTextField(
            hint: l10n.epLinkLabel,
            semanticLabel: l10n.epLinkLabel,
            controller: row.label,
            maxLength: 30,
            errorText: row.labelError,
            textInputAction: TextInputAction.next,
            onChanged: (_) {
              row.labelError = null;
              onChanged();
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: AtTextField(
            hint: l10n.epLinkUrl,
            semanticLabel: l10n.epLinkUrl,
            controller: row.url,
            keyboardType: TextInputType.url,
            errorText: row.urlError,
            textInputAction: TextInputAction.next,
            onChanged: (_) {
              row.urlError = null;
              onChanged();
            },
          ),
        ),
        AtIconButton(
          icon: LucideIcons.x,
          semanticLabel: l10n.epRemoveLink,
          onPressed: onRemove,
        ),
      ],
    );
  }
}
