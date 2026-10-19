import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/providers.dart';
import '../../core/routing/routes.dart';
import '../profile/profile_providers.dart';
import 'portfolio_common.dart';
import 'portfolio_providers.dart';

/// My services: what the member offers on their profile. Marketplace listings arrive in Phase 2, so each
/// service stays "Profile only" and the marketplace actions open their labelled screen.
class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, [
    ServiceDto? existing,
  ]) async {
    final l10n = AppLocalizations.of(context);
    final changed = await showAtBottomSheet<bool>(
      context: context,
      title: existing == null ? l10n.svAddTitle : l10n.svEditTitle,
      builder: (_) => _ServiceSheet(existing: existing),
    );
    if (changed == true) {
      ref.invalidate(myServicesProvider);
      ref.invalidate(myProfileProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(myServicesProvider);
    return PortfolioScaffold(
      title: l10n.pfServices,
      addLabel: l10n.svAddTitle,
      onBack: () =>
          context.canPop() ? context.pop() : context.go(Routes.profile),
      onAdd: () => _edit(context, ref),
      body: AsyncBody<List<ServiceDto>>(
        value: items,
        onRetry: () => ref.invalidate(myServicesProvider),
        builder: (list) => list.isEmpty
            ? AtEmptyState(
                icon: LucideIcons.handshake,
                title: l10n.svEmptyTitle,
                body: l10n.svEmptyBody,
                tone: AtTone.pink,
                ctaLabel: l10n.svAddTitle,
                onCta: () => _edit(context, ref),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AtSpacing.gutter,
                  8,
                  AtSpacing.gutter,
                  AtSpacing.xl,
                ),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final s = list[i];
                  return AtCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.title,
                                style: AtTextStyles.cardTitle.copyWith(
                                  color: AtColors.ink,
                                ),
                              ),
                            ),
                            AtTag(
                              label: s.status == ServiceDtoStatus.onMarketplace
                                  ? l10n.svOnMarketplace
                                  : l10n.svProfileOnly,
                              tone: AtTone.neutral,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          priceText(l10n, s),
                          style: AtTextStyles.chip.copyWith(
                            color: AtColors.primary,
                          ),
                        ),
                        if (s.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            s.description!,
                            style: AtTextStyles.bodySm.copyWith(
                              color: AtColors.body,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            _Action(
                              label: l10n.svPublish,
                              icon: LucideIcons.store,
                              onTap: () => context.push(
                                Routes.soonPath('p2', name: l10n.svPublish),
                              ),
                            ),
                            _Action(
                              label: l10n.svViewListing,
                              icon: LucideIcons.externalLink,
                              onTap: () => context.push(
                                Routes.soonPath('p2', name: l10n.svViewListing),
                              ),
                            ),
                            _Action(
                              label: l10n.svEdit,
                              icon: LucideIcons.pencil,
                              onTap: () => _edit(context, ref, s),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AtTapTarget(
    semanticLabel: label,
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AtColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AtTextStyles.chip.copyWith(color: AtColors.primary),
          ),
        ],
      ),
    ),
  );
}

class _ServiceSheet extends ConsumerStatefulWidget {
  const _ServiceSheet({this.existing});

  final ServiceDto? existing;

  @override
  ConsumerState<_ServiceSheet> createState() => _ServiceSheetState();
}

class _ServiceSheetState extends ConsumerState<_ServiceSheet> {
  late final _title = TextEditingController(text: widget.existing?.title);
  late final _description = TextEditingController(
    text: widget.existing?.description,
  );
  late final _min = TextEditingController(
    text: widget.existing?.priceMin?.round().toString() ?? '',
  );
  late final _max = TextEditingController(
    text: widget.existing?.priceMax?.round().toString() ?? '',
  );
  late int _type = switch (widget.existing?.priceType) {
    ServiceDtoPriceType.fixed => 0,
    ServiceDtoPriceType.range => 1,
    _ => 2,
  };

  bool _busy = false;
  String? _titleError;
  String? _minError;
  String? _maxError;
  String? _banner;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final min = int.tryParse(_min.text.trim());
    final max = int.tryParse(_max.text.trim());
    _titleError = _title.text.trim().length < 2 ? l10n.svTitleError : null;
    _minError = _type != 2 && min == null ? l10n.svPriceError : null;
    _maxError = _type == 1 && (max == null || (min != null && max < min))
        ? l10n.svMaxError
        : null;
    _banner = null;
    if (_titleError != null || _minError != null || _maxError != null) {
      setState(() {});
      return;
    }
    setState(() => _busy = true);
    final repo = ref.read(portfolioRepositoryProvider);
    try {
      final existing = widget.existing;
      final description = _description.text.trim();
      if (existing == null) {
        await repo.addService(
          ServiceInputDto(
            title: _title.text.trim(),
            description: description.isEmpty ? null : description,
            priceType: switch (_type) {
              0 => ServiceInputDtoPriceType.fixed,
              1 => ServiceInputDtoPriceType.range,
              _ => ServiceInputDtoPriceType.onRequest,
            },
            priceMin: _type == 2 ? null : min,
            priceMax: _type == 1 ? max : null,
          ),
        );
      } else {
        await repo.updateService(
          existing.id,
          UpdateServiceDto(
            title: _title.text.trim(),
            description: description,
            priceType: switch (_type) {
              0 => UpdateServiceDtoPriceType.fixed,
              1 => UpdateServiceDtoPriceType.range,
              _ => UpdateServiceDtoPriceType.onRequest,
            },
            priceMin: _type == 2 ? null : min,
            priceMax: _type == 1 ? max : null,
          ),
        );
      }
      ref.read(analyticsProvider).track('service_saved');
      if (mounted) Navigator.of(context).pop(true);
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _titleError = e.fieldError('title');
        _minError = e.fieldError('priceMin');
        _maxError = e.fieldError('priceMax');
        _banner = (_titleError ?? _minError ?? _maxError) == null
            ? e.message
            : null;
      });
    } on AppFailure catch (e) {
      if (mounted) setState(() => _banner = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirmSheet(
      context,
      title: l10n.svDeleteTitle,
      body: l10n.svDeleteBody,
      actionLabel: l10n.svDelete,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(portfolioRepositoryProvider)
          .deleteService(widget.existing!.id);
      if (mounted) Navigator.of(context).pop(true);
    } on AppFailure catch (e) {
      if (mounted) setState(() => _banner = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final digits = [FilteringTextInputFormatter.digitsOnly];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_banner != null) ...[
          AtInlineBanner(message: _banner!, tone: AtBannerTone.error),
          const SizedBox(height: 12),
        ],
        AtTextField(
          key: const ValueKey('svTitleLabel'),
          label: l10n.svTitleLabel,
          controller: _title,
          maxLength: 80,
          errorText: _titleError,
        ),
        const SizedBox(height: 12),
        AtTextField(
          key: const ValueKey('svDescriptionLabel'),
          label: l10n.svDescriptionLabel,
          controller: _description,
          minLines: 2,
          maxLines: 4,
          maxLength: 600,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.svPriceTypeLabel,
          style: AtTextStyles.label.copyWith(color: AtColors.ink),
        ),
        const SizedBox(height: 8),
        AtSegmented(
          labels: [l10n.svTypeFixed, l10n.svTypeRange, l10n.svTypeOnRequest],
          selectedIndex: _type,
          onChanged: (i) => setState(() => _type = i),
        ),
        if (_type != 2) ...[
          const SizedBox(height: 12),
          AtTextField(
            key: const ValueKey('svMin'),
            label: _type == 1 ? l10n.svMinLabel : l10n.svPriceLabel,
            prefixText: 'KES ',
            controller: _min,
            keyboardType: TextInputType.number,
            inputFormatters: digits,
            maxLength: 9,
            errorText: _minError,
          ),
        ],
        if (_type == 1) ...[
          const SizedBox(height: 12),
          AtTextField(
            key: const ValueKey('svMaxLabel'),
            label: l10n.svMaxLabel,
            prefixText: 'KES ',
            controller: _max,
            keyboardType: TextInputType.number,
            inputFormatters: digits,
            maxLength: 9,
            errorText: _maxError,
          ),
        ],
        const SizedBox(height: 20),
        AtButton(label: l10n.save, loading: _busy, onPressed: _save),
        if (widget.existing != null) ...[
          const SizedBox(height: 8),
          AtButton(
            label: l10n.svDelete,
            variant: AtButtonVariant.destructive,
            onPressed: _busy ? null : _delete,
          ),
        ],
      ],
    );
  }
}
