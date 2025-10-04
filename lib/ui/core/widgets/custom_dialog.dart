import 'package:flutter/material.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  required Widget content,
  List<Widget>? actions, // Ahora es opcional
  bool includeCancel = true, // Controla si agregamos botón Cancelar automáticamente
}) {
  final colors = Theme.of(context).colorScheme;
  final fonts = Theme.of(context).textTheme;

  // Creamos la lista de acciones final
  final List<Widget> dialogActions = [];

  // Si includeCancel es true, agregamos botón Cancelar por defecto
  if (includeCancel) {
    dialogActions.add(
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          "Cancelar",
          style: TextStyle(color: colors.primary),
        ),
      ),
    );
  }

  // Agregamos las acciones personalizadas si se pasaron
  if (actions != null) {
    dialogActions.addAll(actions);
  }

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: fonts.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: content,
      actions: dialogActions,
    ),
  );
}
