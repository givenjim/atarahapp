import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/routing/routes.dart';
import '../discover/discover_common.dart';
import '../portfolio/media_seams.dart';
import '../portfolio/portfolio_providers.dart';
import '../portfolio/portfolio_repository.dart';
import 'marketplace_providers.dart';

const _maxMedia = 8;
const _maxProjects = 6;
const _maxIncluded = 10;

/// One picture in the Media step: already on the listing, or being uploaded now.
class _Pic {
  _Pic.existing(this.mediaId, this.url)
    : file = null,
      state = AtMediaTileState.ready;
  _Pic.picked(this.file)
    : mediaId = null,
      url = null,
      state = AtMediaTileState.uploading;

  String? mediaId;
  final String? url;
  final PickedMedia? file;
  AtMediaTileState state;
  double progress = 0;
}

/// `listing_new`: the four steps (Details, Media, Pricing, Preview) for a new listing, and the same flow to edit an
/// existing one. "Save draft" keeps the work; Preview ends with Submit. A member who is not a seller yet is shown
/// the seller terms first: accepting them is what makes them a seller when the first listing is created.
class ListingEditorScreen extends ConsumerWidget {
  const ListingEditorScreen({super.key, this.listingId});

  final String? listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (listingId == null) return const _Editor();
    final provider = myListingProvider(listingId!);
    final async = ref.watch(provider);
    return async.when(
      loading: () => const Scaffold(body: AtLoadingBody()),
      error: (e, _) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              AtTopBar(
                onBack: () => context.canPop()
                    ? context.pop()
                    : context.go(Routes.myListings),
              ),
              Expanded(
                child: loadFailure(e, () => ref.invalidate(provider), l10n),
              ),
            ],
          ),
        ),
      ),
      data: (l) => _Editor(existing: l),
    );
  }
}

class _Editor extends ConsumerStatefulWidget {
  const _Editor({this.existing});

  final MyListingDto? existing;

  @override
  ConsumerState<_Editor> createState() => _EditorState();
}

class _EditorState extends ConsumerState<_Editor> {
  int _step = 0;
  String? _id;
  bool _busy = false;
  bool _dirty = false;
  bool _termsAccepted = false;
  String? _termsVersion;
  String? _banner;
  List<String> _missing = const [];

  ListingType _type = ListingType.service;
  String? _categoryId;
  String? _categoryName;
  WorkMode _mode = WorkMode.remote;
  PricingType _pricing = PricingType.fixed;
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _audience = TextEditingController();
  final _delivery = TextEditingController();
  final _location = TextEditingController();
  final _item = TextEditingController();
  final _min = TextEditingController();
  final _max = TextEditingController();
  final List<String> _included = [];
  final List<_Pic> _pics = [];
  final Set<String> _projects = {};
  String? _titleError;
  String? _categoryError;
  String? _minError;
  String? _maxError;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _id = e.id;
      _type = e.type;
      _categoryId = e.categoryId;
      _categoryName = e.categoryName;
      _mode = e.workMode;
      _pricing = e.pricingType;
      _title.text = e.title;
      _description.text = e.description;
      _audience.text = e.audienceText ?? '';
      _delivery.text = e.deliveryDays?.toInt().toString() ?? '';
      _location.text = e.locationText ?? '';
      _min.text = e.priceMin?.toInt().toString() ?? '';
      _max.text = e.priceMax?.toInt().toString() ?? '';
      _included.addAll(e.includedItems);
      for (final m in e.media) {
        _pics.add(_Pic.existing(m.id, m.url));
      }
      _projects.addAll(e.portfolio.map((p) => p.id));
      _missing = e.missing;
      _termsAccepted = true;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _ensureTerms());
    }
    for (final c in [_title, _description, _audience, _delivery, _location]) {
      c.addListener(() => _dirty = true);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _title,
      _description,
      _audience,
      _delivery,
      _location,
      _item,
      _min,
      _max,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// A member who is already a seller goes straight in; anyone else sees the terms first.
  Future<void> _ensureTerms() async {
    final mine = await ref
        .read(myListingsProvider.future)
        .catchError(
          (_) => const MyListingsDto(
            isSeller: false,
            sellerStatus: null,
            stats: MyListingsStatsDto(live: 0, newInterest: 0, views30d: 0),
            listings: [],
          ),
        );
    if (!mounted) return;
    if (mine.isSeller) {
      _termsAccepted = true;
      return;
    }
    final terms = await showAtBottomSheet<SellerTermsDto>(
      context: context,
      title: AppLocalizations.of(context).mkTermsTitle,
      builder: (_) => const SellerTermsSheet(),
    );
    if (!mounted) return;
    if (terms == null) {
      context.canPop() ? context.pop() : context.go(Routes.marketplace);
      return;
    }
    setState(() {
      _termsAccepted = true;
      _termsVersion = terms.version;
    });
  }

  // ---- values ----

  int? _int(TextEditingController c) => int.tryParse(c.text.trim());

  ListingFieldsDto _fields() => ListingFieldsDto(
    type: _type,
    title: _title.text.trim(),
    categoryId: _categoryId,
    description: _description.text.trim(),
    includedItems: _included,
    deliveryDays: _int(_delivery) ?? 0,
    workMode: _mode,
    locationText: _location.text.trim(),
    audienceText: _audience.text.trim(),
    pricingType: _pricing,
    priceMin: _pricing == PricingType.onRequest ? null : _int(_min),
    priceMax: _pricing == PricingType.range ? _int(_max) : null,
    mediaIds: [
      for (final p in _pics)
        if (p.mediaId != null) p.mediaId!,
    ],
    projectIds: _projects.toList(),
  );

  bool _validateDetails(AppLocalizations l10n) {
    _titleError = _title.text.trim().length < 4 ? l10n.mkTitleError : null;
    _categoryError = _categoryId == null ? l10n.mkCategoryError : null;
    return _titleError == null && _categoryError == null;
  }

  bool _validatePricing(AppLocalizations l10n) {
    final min = _int(_min);
    final max = _int(_max);
    _minError = _pricing != PricingType.onRequest && min == null
        ? l10n.mkPriceError
        : null;
    _maxError =
        _pricing == PricingType.range &&
            (max == null || (min != null && max < min))
        ? l10n.mkPriceMaxError
        : null;
    return _minError == null && _maxError == null;
  }

  /// Creates the draft the first time and updates it after. Returns whether the server has the latest.
  Future<bool> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_pics.any((p) => p.state == AtMediaTileState.uploading)) return false;
    if (!_validateDetails(l10n)) {
      setState(() => _step = 0);
      return false;
    }
    if (_pricing != PricingType.onRequest && !_validatePricing(l10n)) {
      setState(() => _step = 2);
      return false;
    }
    setState(() {
      _busy = true;
      _banner = null;
    });
    final repo = ref.read(marketplaceRepositoryProvider);
    try {
      final f = _fields();
      final MyListingDto saved;
      if (_id == null) {
        saved = await repo.create(
          CreateListingDto(
            type: f.type,
            title: f.title,
            categoryId: f.categoryId,
            description: f.description,
            includedItems: f.includedItems,
            deliveryDays: f.deliveryDays,
            workMode: f.workMode,
            locationText: f.locationText,
            audienceText: f.audienceText,
            pricingType: f.pricingType,
            priceMin: f.priceMin,
            priceMax: f.priceMax,
            mediaIds: f.mediaIds,
            projectIds: f.projectIds,
            acceptTerms: _termsAccepted ? true : null,
            termsVersion: _termsVersion,
          ),
        );
      } else {
        saved = await repo.update(_id!, f);
      }
      _id = saved.id;
      _missing = saved.missing;
      _dirty = false;
      ref.invalidate(myListingsProvider);
      ref.invalidate(myListingProvider(saved.id));
      return true;
    } on ApiFailure catch (e) {
      if (mounted) {
        setState(() {
          _titleError = e.fieldError('title');
          _banner = e.message;
        });
      }
      return false;
    } on AppFailure catch (e) {
      if (mounted) setState(() => _banner = e.message);
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _next() async {
    final l10n = AppLocalizations.of(context);
    if (_step == 0 && !_validateDetails(l10n)) {
      setState(() {});
      return;
    }
    if (_step == 2 && !_validatePricing(l10n)) {
      setState(() {});
      return;
    }
    if (_step == 0 || _step == 2) {
      // Saving after Details creates the draft; the rest of the flow edits it.
      if (_step == 2 && !await _save()) return;
    }
    if (!mounted) return;
    setState(() {
      _step = (_step + 1).clamp(0, 3);
      if (_step == 3 && _id == null) _step = 2;
    });
    if (_step == 3) unawaited(_save());
  }

  Future<void> _saveDraft() async {
    final ok = await _save();
    if (ok && mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.mkDraftSaved)));
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!await _save() || _id == null || !mounted) return;
    setState(() {
      _busy = true;
      _banner = null;
    });
    try {
      final res = await ref.read(marketplaceRepositoryProvider).submit(_id!);
      ref.invalidate(myListingsProvider);
      ref.invalidate(marketplaceHomeProvider);
      ref.invalidate(myProjectsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res.published ? l10n.mkPublishedNow : l10n.mkSubmittedReview,
          ),
        ),
      );
      context.canPop() ? context.pop() : context.go(Routes.myListings);
    } on ApiFailure catch (e) {
      if (!mounted) return;
      final missing = e.details['missing'];
      setState(() {
        _banner = e.message;
        if (missing is List) {
          _missing = [
            for (final m in missing)
              if (m is Map && m['message'] != null) m['message'].toString(),
          ];
        }
      });
    } on AppFailure catch (e) {
      if (mounted) setState(() => _banner = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _leave() async {
    if (!_dirty) {
      context.canPop() ? context.pop() : context.go(Routes.marketplace);
      return;
    }
    final l10n = AppLocalizations.of(context);
    final leave = await showAtBottomSheet<bool>(
      context: context,
      title: l10n.mkLeaveTitle,
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.mkLeaveBody,
            style: AtTextStyles.bodySm.copyWith(color: context.at.body),
          ),
          const SizedBox(height: 16),
          AtButton(
            label: l10n.mkLeave,
            variant: AtButtonVariant.destructive,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
          const SizedBox(height: 8),
          AtButton(
            label: l10n.mkSaveDraft,
            variant: AtButtonVariant.secondary,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
        ],
      ),
    );
    if (!mounted || leave == null) return;
    if (leave == false && !await _save()) return;
    if (mounted) {
      context.canPop() ? context.pop() : context.go(Routes.marketplace);
    }
  }

  // ---- pictures ----

  Future<void> _addPictures() async {
    final room = _maxMedia - _pics.length;
    if (room <= 0) return;
    try {
      final picked = await ref
          .read(mediaPickerProvider)
          .pick(MediaPickKind.photos, limit: room);
      for (final f in picked.take(room)) {
        final pic = _Pic.picked(f);
        setState(() {
          _pics.add(pic);
          _dirty = true;
        });
        unawaited(_upload(pic));
      }
    } on Object {
      if (mounted) {
        setState(() => _banner = AppLocalizations.of(context).mkUploadFailed);
      }
    }
  }

  Future<void> _upload(_Pic pic) async {
    try {
      final id = await ref
          .read(portfolioRepositoryProvider)
          .uploadMedia(
            pic.file!,
            onProgress: (p) {
              if (mounted) setState(() => pic.progress = p);
            },
          );
      if (!mounted) return;
      setState(() {
        pic.mediaId = id;
        pic.state = AtMediaTileState.ready;
      });
    } on Object {
      if (mounted) setState(() => pic.state = AtMediaTileState.failed);
    }
  }

  // ---- build ----

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = [
      l10n.mkStepDetails,
      l10n.mkStepMedia,
      l10n.mkStepPricing,
      l10n.mkStepPreview,
    ];
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        backgroundColor: context.at.background,
        body: AtPage(
          child: Column(
            children: [
              AtTopBar(
                title: widget.existing == null
                    ? l10n.mkNewTitle
                    : l10n.mkEditTitle,
                onBack: _leave,
                actions: [
                  AtChip(
                    label: l10n.mkSaveDraft,
                    onTap: _busy ? null : _saveDraft,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AtSpacing.gutter,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AtStepper(steps: 4, current: _step + 1),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.mkStepOf(_step + 1, 4)} · ${steps[_step]}',
                      style: AtTextStyles.meta.copyWith(
                        color: context.at.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AtSpacing.gutter,
                    16,
                    AtSpacing.gutter,
                    24,
                  ),
                  children: [
                    if (_banner != null) ...[
                      AtInlineBanner(
                        message: _banner!,
                        tone: AtBannerTone.error,
                      ),
                      const SizedBox(height: 12),
                    ],
                    switch (_step) {
                      0 => _details(context, l10n),
                      1 => _media(context, l10n),
                      2 => _pricingStep(context, l10n),
                      _ => _preview(context, l10n),
                    },
                  ],
                ),
              ),
              _Footer(
                step: _step,
                busy: _busy,
                onBack: _step == 0 ? null : () => setState(() => _step--),
                onNext: _step == 3 ? _submit : _next,
                nextLabel: _step == 3 ? l10n.mkSubmit : l10n.mkNext,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _details(BuildContext context, AppLocalizations l10n) {
    final cats = ref.watch(marketplaceCategoriesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.mkTypeLabel,
          style: AtTextStyles.label.copyWith(color: context.at.ink),
        ),
        const SizedBox(height: 8),
        AtSegmented(
          labels: [l10n.mkTypeService, l10n.mkTypeProduct],
          selectedIndex: _type == ListingType.service ? 0 : 1,
          onChanged: (i) => setState(() {
            _type = i == 0 ? ListingType.service : ListingType.product;
            _dirty = true;
          }),
        ),
        const SizedBox(height: 16),
        AtTextField(
          label: l10n.mkTitleLabel,
          controller: _title,
          maxLength: 100,
          errorText: _titleError,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.mkCategoryLabel,
          style: AtTextStyles.label.copyWith(color: context.at.ink),
        ),
        const SizedBox(height: 8),
        cats.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => loadFailure(
            e,
            () => ref.invalidate(marketplaceCategoriesProvider),
            l10n,
          ),
          data: (list) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in list)
                AtChip(
                  label: c.name,
                  selected: c.id == _categoryId,
                  onTap: () => setState(() {
                    _categoryId = c.id;
                    _categoryName = c.name;
                    _categoryError = null;
                    _dirty = true;
                  }),
                ),
            ],
          ),
        ),
        if (_categoryError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _categoryError!,
              style: AtTextStyles.meta.copyWith(color: context.at.coralStrong),
            ),
          ),
        const SizedBox(height: 12),
        AtTextField(
          label: l10n.mkDescriptionLabel,
          controller: _description,
          minLines: 4,
          maxLines: 8,
          maxLength: 4000,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.mkIncludedLabel,
          style: AtTextStyles.label.copyWith(color: context.at.ink),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < _included.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: AtChip(
              label: _included[i],
              kind: AtChipKind.removable,
              onRemove: () => setState(() {
                _included.removeAt(i);
                _dirty = true;
              }),
              removeSemanticLabel: _included[i],
            ),
          ),
        if (_included.length < _maxIncluded)
          Row(
            children: [
              Expanded(
                child: AtTextField(
                  label: l10n.mkIncludedHint,
                  controller: _item,
                  maxLength: 120,
                  onSubmitted: (_) => _addItem(),
                ),
              ),
              const SizedBox(width: 8),
              AtIconButton(
                icon: LucideIcons.plus,
                semanticLabel: l10n.mkIncludedHint,
                onPressed: _addItem,
              ),
            ],
          ),
        const SizedBox(height: 12),
        AtTextField(
          label: l10n.mkAudienceLabel,
          controller: _audience,
          maxLength: 240,
        ),
        const SizedBox(height: 12),
        AtTextField(
          label: l10n.mkDeliveryLabel,
          controller: _delivery,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 3,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.mkWorkModeLabel,
          style: AtTextStyles.label.copyWith(color: context.at.ink),
        ),
        const SizedBox(height: 8),
        AtSegmented(
          labels: [l10n.mkModeRemote, l10n.mkModeOnsite, l10n.mkModeHybrid],
          selectedIndex: switch (_mode) {
            WorkMode.remote => 0,
            WorkMode.onsite => 1,
            _ => 2,
          },
          onChanged: (i) => setState(() {
            _mode = [WorkMode.remote, WorkMode.onsite, WorkMode.hybrid][i];
            _dirty = true;
          }),
        ),
        if (_mode != WorkMode.remote) ...[
          const SizedBox(height: 12),
          AtTextField(
            label: l10n.mkLocationLabel,
            controller: _location,
            maxLength: 80,
          ),
        ],
      ],
    );
  }

  void _addItem() {
    final v = _item.text.trim();
    if (v.isEmpty || _included.length >= _maxIncluded) return;
    setState(() {
      _included.add(v);
      _item.clear();
      _dirty = true;
    });
  }

  Widget _media(BuildContext context, AppLocalizations l10n) {
    final projects = ref.watch(myProjectsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.mkMediaTitle,
          style: AtTextStyles.sectionTitleSm.copyWith(color: context.at.ink),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.mkMediaBody,
          style: AtTextStyles.bodySm.copyWith(color: context.at.body),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var i = 0; i < _pics.length; i++)
              AtMediaTile(
                image: _pics[i].file != null
                    ? FileImage(File(_pics[i].file!.path))
                    : (_pics[i].url == null
                          ? null
                          : NetworkImage(_pics[i].url!)),
                state: _pics[i].state,
                progress: _pics[i].progress,
                onRemove: () => setState(() {
                  _pics.removeAt(i);
                  _dirty = true;
                }),
                onRetry: () => unawaited(_upload(_pics[i])),
                semanticLabel: '${i + 1}',
              ),
          ],
        ),
        if (_pics.length < _maxMedia) ...[
          const SizedBox(height: 12),
          AtUploadZone(label: l10n.mkMediaAdd, onTap: _addPictures),
        ],
        const SizedBox(height: 24),
        Text(
          l10n.mkProjectsTitle,
          style: AtTextStyles.sectionTitleSm.copyWith(color: context.at.ink),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.mkProjectsBody,
          style: AtTextStyles.bodySm.copyWith(color: context.at.body),
        ),
        const SizedBox(height: 8),
        projects.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              loadFailure(e, () => ref.invalidate(myProjectsProvider), l10n),
          data: (all) {
            final published = all
                .where((p) => p.status == ProjectCardDtoStatus.published)
                .toList();
            if (published.isEmpty) {
              return Text(
                l10n.mkProjectsNone,
                style: AtTextStyles.body.copyWith(color: context.at.muted),
              );
            }
            return Column(
              children: [
                for (final p in published)
                  AtCheckbox(
                    value: _projects.contains(p.id),
                    label: p.title,
                    onChanged: (v) => setState(() {
                      if (v && _projects.length < _maxProjects) {
                        _projects.add(p.id);
                      } else {
                        _projects.remove(p.id);
                      }
                      _dirty = true;
                    }),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _pricingStep(BuildContext context, AppLocalizations l10n) {
    final digits = [FilteringTextInputFormatter.digitsOnly];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.mkPricingTitle,
          style: AtTextStyles.sectionTitleSm.copyWith(color: context.at.ink),
        ),
        const SizedBox(height: 12),
        AtSegmented(
          labels: [l10n.mkPriceFixed, l10n.mkPriceRange, l10n.mkPriceOnRequest],
          selectedIndex: switch (_pricing) {
            PricingType.fixed => 0,
            PricingType.range => 1,
            _ => 2,
          },
          onChanged: (i) => setState(() {
            _pricing = [
              PricingType.fixed,
              PricingType.range,
              PricingType.onRequest,
            ][i];
            _dirty = true;
          }),
        ),
        const SizedBox(height: 16),
        if (_pricing == PricingType.onRequest)
          Text(
            l10n.mkPriceOnRequestNote,
            style: AtTextStyles.body.copyWith(color: context.at.body),
          )
        else ...[
          AtTextField(
            label: _pricing == PricingType.range
                ? l10n.mkPriceMin
                : l10n.mkPriceLabel,
            prefixText: 'KES ',
            controller: _min,
            keyboardType: TextInputType.number,
            inputFormatters: digits,
            maxLength: 9,
            errorText: _minError,
            onChanged: (_) => _dirty = true,
          ),
          if (_pricing == PricingType.range) ...[
            const SizedBox(height: 12),
            AtTextField(
              label: l10n.mkPriceMax,
              prefixText: 'KES ',
              controller: _max,
              keyboardType: TextInputType.number,
              inputFormatters: digits,
              maxLength: 9,
              errorText: _maxError,
              onChanged: (_) => _dirty = true,
            ),
          ],
        ],
      ],
    );
  }

  String _priceText() {
    final min = _int(_min);
    final max = _int(_max);
    String kes(int n) => 'KES ${_group(n)}';
    return switch (_pricing) {
      PricingType.onRequest => l10nPriceOnRequest(context),
      PricingType.fixed => min == null ? '' : kes(min),
      _ => min == null ? '' : '${kes(min)} – ${max == null ? '' : kes(max)}',
    };
  }

  String l10nPriceOnRequest(BuildContext context) =>
      AppLocalizations.of(context).mkPriceOnRequest;

  String _group(int n) {
    final s = n.toString();
    final out = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
      out.write(s[i]);
    }
    return out.toString();
  }

  Widget _preview(BuildContext context, AppLocalizations l10n) {
    final cover = _pics.firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.mkPreviewTitle,
          style: AtTextStyles.sectionTitleSm.copyWith(color: context.at.ink),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.mkPreviewNote,
          style: AtTextStyles.bodySm.copyWith(color: context.at.body),
        ),
        const SizedBox(height: 12),
        AtCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: AspectRatio(
                  aspectRatio: 1.5,
                  child: cover == null
                      ? ColoredBox(color: context.at.softTile)
                      : cover.file != null
                      ? Image.file(File(cover.file!.path), fit: BoxFit.cover)
                      : Image.network(cover.url!, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_categoryName != null)
                      AtTag(label: _categoryName!, tone: AtTone.primary),
                    const SizedBox(height: 8),
                    Text(
                      _title.text.trim(),
                      style: AtTextStyles.sectionTitle.copyWith(
                        color: context.at.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _priceText(),
                      style: AtTextStyles.cardTitle.copyWith(
                        color: context.at.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _description.text.trim(),
                      style: AtTextStyles.body.copyWith(color: context.at.body),
                    ),
                    for (final item in _included)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.check,
                              size: 16,
                              color: context.at.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item,
                                style: AtTextStyles.bodySm.copyWith(
                                  color: context.at.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_missing.isNotEmpty) ...[
          const SizedBox(height: 12),
          AtInlineBanner(
            message: '${l10n.mkMissingTitle}: ${_missing.join(' ')}',
            tone: AtBannerTone.info,
          ),
        ],
        const SizedBox(height: 12),
        Text(
          l10n.mkReviewNote,
          style: AtTextStyles.meta.copyWith(color: context.at.muted),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.step,
    required this.busy,
    required this.onBack,
    required this.onNext,
    required this.nextLabel,
  });

  final int step;
  final bool busy;
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.at.surface,
        border: Border(top: BorderSide(color: context.at.cardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AtSpacing.gutter),
          child: Row(
            children: [
              if (onBack != null) ...[
                Expanded(
                  child: AtButton(
                    label: l10n.back,
                    variant: AtButtonVariant.secondary,
                    onPressed: busy ? null : onBack,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: AtButton(
                  label: nextLabel,
                  loading: busy,
                  onPressed: onNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The seller terms. Shows the server's text and marks it when it is only the draft placeholder; accepting returns
/// the terms so the first listing records which version was accepted.
class SellerTermsSheet extends ConsumerStatefulWidget {
  const SellerTermsSheet({super.key});

  @override
  ConsumerState<SellerTermsSheet> createState() => _TermsSheetState();
}

class _TermsSheetState extends ConsumerState<SellerTermsSheet> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(sellerTermsProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) =>
          loadFailure(e, () => ref.invalidate(sellerTermsProvider), l10n),
      data: (terms) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (terms.isDraft) ...[
            Row(
              children: [
                AtTag(label: l10n.mkTermsDraftBadge, tone: AtTone.warning),
              ],
            ),
            const SizedBox(height: 8),
            AtInlineBanner(
              message: l10n.mkTermsDraftNotice,
              tone: AtBannerTone.info,
            ),
            const SizedBox(height: 12),
          ],
          Text(
            terms.body,
            style: AtTextStyles.bodySm.copyWith(color: context.at.body),
          ),
          const SizedBox(height: 16),
          AtCheckbox(
            value: _accepted,
            label: l10n.mkTermsAccept,
            onChanged: (v) => setState(() => _accepted = v),
          ),
          const SizedBox(height: 16),
          AtButton(
            label: l10n.mkTermsContinue,
            onPressed: _accepted
                ? () => Navigator.of(context).pop(terms)
                : null,
          ),
        ],
      ),
    );
  }
}
