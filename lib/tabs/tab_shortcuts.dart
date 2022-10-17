import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shortcut_store/shortcut_store.dart';

import 'tab_model.dart';

class TabShortcuts extends StatelessWidget {
  const TabShortcuts({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final length = context.select<TabModel, int>((m) => m.length);
    final model = context.read<TabModel>();
    final shortcuts = ShortcutStore.of(context);

    return CallbackShortcuts(
      bindings: {
        for (final shortcut in shortcuts.get('tab-new')) shortcut: model.newTab,
        if (length > 1)
          for (final shortcut in shortcuts.get('tab-close'))
            shortcut: model.closeTab,
        for (final shortcut in shortcuts.get('tab-next'))
          shortcut: model.nextTab,
        for (final shortcut in shortcuts.get('tab-previous'))
          shortcut: model.previousTab,
      },
      child: child,
    );
  }
}