import 'package:flutter/material.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  required Widget content,
  required List<Widget> actions,
}) {
  final colors = Theme.of(context).colorScheme;
  final fonts = Theme.of(context).textTheme;

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: fonts.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      content: content,
      actions: actions,
    ),
  );
}
