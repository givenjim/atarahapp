import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/networking/failures.dart';
import '../../discover/discover_common.dart';
import 'people_providers.dart';

/// A kind sentence for something that went wrong while connecting, accepting, unblocking and so on.
/// Never shows raw server text for the cases the member can act on.
String peopleFailureMessage(AppLocalizations l10n, AppFailure failure) {
  if (failure is ApiFailure) {
    if (failure.code == 'VERIFICATION_REQUIRED') {
      return l10n.peopleErrVerification;
    }
    if (failure.code == 'ACCOUNT_RESTRICTED' ||
        (failure.code == 'FORBIDDEN' &&
            failure.reason == 'ACCOUNT_RESTRICTED')) {
      return l10n.peopleErrRestricted;
    }
    if (failure.code == 'RATE_LIMITED') return l10n.peopleErrRateLimited;
    if (failure.code == 'RESOURCE_NOT_FOUND') return l10n.peopleErrNotFound;
    return l10n.cpActionFailed;
  }
  if (failure is NetworkFailure) return failure.message;
  return l10n.cpActionFailed;
}

/// The loading / failed / empty / items / load-more states of one paged list, drawn as a column of widgets.
class PagedSection<T> extends StatelessWidget {
  const PagedSection({
    super.key,
    required this.async,
    required this.retry,
    required this.loadMore,
    required this.empty,
    required this.item,
    this.skeletonHeight = 120,
  });

  final AsyncValue<Paged<T>> async;
  final VoidCallback retry;
  final VoidCallback loadMore;
  final Widget Function() empty;
  final Widget Function(T) item;
  final double skeletonHeight;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return async.when(
      loading: () => Column(
        children: [
          for (var i = 0; i < 3; i++) ...[
            AtSkeleton(height: skeletonHeight, radius: 18),
            const SizedBox(height: 12),
          ],
        ],
      ),
      error: (e, _) => loadFailure(e, retry, l10n),
      data: (page) {
        if (page.items.isEmpty) return empty();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final t in page.items) ...[
              item(t),
              const SizedBox(height: AtSpacing.listGap),
            ],
            if (page.loadingMore)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (page.moreFailed)
              AtButton(
                label: l10n.retry,
                variant: AtButtonVariant.tertiary,
                onPressed: loadMore,
              ),
          ],
        );
      },
    );
  }
}

/// A small count pill ("3") for requests waiting.
class CountPill extends StatelessWidget {
  const CountPill({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
    padding: const EdgeInsets.symmetric(horizontal: 6),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: context.at.primaryFill,
      borderRadius: AtRadii.pill,
    ),
    child: Text(
      count > 99 ? '99+' : '$count',
      style: AtTextStyles.metaSm.copyWith(
        color: context.at.white,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

/// A person as a row: picture, name, what they do and a line of detail. [trailing] sits under the text.
class PersonRowTile extends StatelessWidget {
  const PersonRowTile({
    super.key,
    required this.name,
    required this.avatarUrl,
    this.subtitle,
    this.detail,
    this.actions,
    this.onTap,
  });

  final String name;
  final String? avatarUrl;
  final String? subtitle;
  final String? detail;
  final Widget? actions;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AtCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Portrait(name: name, url: avatarUrl, size: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AtTextStyles.cardTitle.copyWith(
                        color: context.at.ink,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AtTextStyles.bodySm.copyWith(
                          color: context.at.body,
                        ),
                      ),
                    if (detail != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          detail!,
                          style: AtTextStyles.metaSm.copyWith(
                            color: context.at.muted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (actions != null) ...[const SizedBox(height: 12), actions!],
        ],
      ),
    );
  }
}

/// The two ways into the rest of the People area: the connections lists and, from the overflow, blocked people.
class OverflowSheet extends StatelessWidget {
  const OverflowSheet({super.key, required this.onBlocked});

  final VoidCallback onBlocked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AtSpacing.gutter,
        0,
        AtSpacing.gutter,
        20,
      ),
      child: AtListRow(
        icon: LucideIcons.userX,
        title: l10n.peopleBlocked,
        subtitle: l10n.peopleBlockedBody,
        onTap: onBlocked,
      ),
    );
  }
}
