import 'package:material_ui/material_ui.dart';

/// Maps persisted subject icon code points to compile-time constant [IconData]s.
class SubjectIcons {
  SubjectIcons._();

  static const List<IconData> options = [
    Icons.menu_book_rounded,
    Icons.code_rounded,
    Icons.storage_rounded,
    Icons.computer_rounded,
    Icons.hub_rounded,
    Icons.security_rounded,
    Icons.cloud_queue_rounded,
    Icons.psychology_rounded,
  ];

  /// Returns a compile-time constant [IconData] matching [codePoint].
  static IconData fromCodePoint(int codePoint) {
    if (codePoint == Icons.code.codePoint) return Icons.code;
    for (final icon in options) {
      if (icon.codePoint == codePoint) return icon;
    }
    return Icons.menu_book_rounded;
  }
}
