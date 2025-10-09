import 'package:flutter/material.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  required Widget content,
  required VoidCallback onSave, // Acción del botón Guardar
  bool includeCancel = true, // Controla si agregamos botón Cancelar
  String saveLabel = "Guardar",
  String cancelLabel = "Cancelar",
}) {
  final colors = Theme.of(context).colorScheme;
  final fonts = Theme.of(context).textTheme;

  final List<Widget> dialogActions = [];

  // Botón Cancelar (idéntico al de Guardar, pero con colores secundarios)
  if (includeCancel) {
    dialogActions.add(
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.secondaryContainer,
          foregroundColor: colors.onSecondaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        onPressed: () => Navigator.pop(context),
        child: Text(cancelLabel),
      ),
    );
  }

  // 🔹 Botón Guardar (acción principal)
  dialogActions.add(
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      onPressed: () {
        onSave();
        Navigator.pop(context);
      },
      child: Text(saveLabel),
    ),
  );

  // 🔹 Mostrar el diálogo
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
