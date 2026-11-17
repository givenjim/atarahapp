import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/design_system.dart';
import '../../core/networking/failures.dart';
import '../../core/routing/routes.dart';

/// The plain-language message of a failure (typed failures carry one; anything else gets the generic one).
String failureMessage(Object e) =>
    e is AppFailure ? e.message : const UnexpectedFailure().message;

void showNotice(BuildContext context, String message) {
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// A screen with a back button and a title: how every settings sub-screen and list in this milestone is framed.
class SubPage extends StatelessWidget {
  const SubPage({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
    this.backTo = Routes.settings,
    this.wash = AtWash.settings,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  /// Where Back goes when there is nothing to pop (a deep link opened this screen).
  final String backTo;
  final AtWash wash;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.at.background,
      body: AtPage(
        wash: wash,
        child: Column(
          children: [
            AtTopBar(
              title: title,
              actions: actions,
              onBack: () =>
                  context.canPop() ? context.pop() : context.go(backTo),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

/// A small caption above a group of rows ("Support", "Account").
class GroupLabel extends StatelessWidget {
  const GroupLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(6, 18, 6, 8),
    child: Semantics(
      header: true,
      child: Text(
        text,
        style: AtTextStyles.label.copyWith(color: context.at.muted),
      ),
    ),
  );
}
