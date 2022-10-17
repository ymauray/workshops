import 'package:flutter/widgets.dart';
import 'package:shortcut_store/shortcut_store.dart';
import 'package:terminal_view/terminal_view.dart';

Map<ShortcutActivator, Intent> buildTerminalShortcuts(BuildContext context) {
  final shortcuts = ShortcutStore.of(context);
  return {
    // edit
    for (final shortcut in shortcuts.get('terminal-copy'))
      shortcut: TerminalIntents.copy,
    for (final shortcut in shortcuts.get('terminal-paste'))
      shortcut: TerminalIntents.paste,
    // scroll
    for (final shortcut in shortcuts.get('terminal-scroll-up'))
      shortcut: TerminalIntents.scrollUp,
    for (final shortcut in shortcuts.get('terminal-scroll-down'))
      shortcut: TerminalIntents.scrollDown,
    for (final shortcut in shortcuts.get('terminal-scroll-page-up'))
      shortcut: TerminalIntents.scrollPageUp,
    for (final shortcut in shortcuts.get('terminal-scroll-page-down'))
      shortcut: TerminalIntents.scrollPageDown,
    for (final shortcut in shortcuts.get('terminal-scroll-to-top'))
      shortcut: TerminalIntents.scrollToTop,
    for (final shortcut in shortcuts.get('terminal-scroll-to-bottom'))
      shortcut: TerminalIntents.scrollToBottom,
    // split
    for (final shortcut in shortcuts.get('terminal-split-auto'))
      shortcut: TerminalIntents.splitAuto,
    // focus
    for (final shortcut in shortcuts.get('terminal-focus-up'))
      shortcut: TerminalIntents.moveFocusUp,
    for (final shortcut in shortcuts.get('terminal-focus-down'))
      shortcut: TerminalIntents.moveFocusDown,
    for (final shortcut in shortcuts.get('terminal-focus-left'))
      shortcut: TerminalIntents.moveFocusLeft,
    for (final shortcut in shortcuts.get('terminal-focus-right'))
      shortcut: TerminalIntents.moveFocusRight,
  };
}