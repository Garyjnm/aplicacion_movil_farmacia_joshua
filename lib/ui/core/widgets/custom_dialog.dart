import 'package:flutter/material.dart';


Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  required Widget content,
  required Future<void> Function() onSave, // Acción del botón Guardar (async)
  bool includeCancel = true,
  String saveLabel = "Guardar",
  String cancelLabel = "Cancelar",
}) {
  final colors = Theme.of(context).colorScheme;
  final fonts = Theme.of(context).textTheme;
  bool isSaving = false; // estado local para evitar doble submit

  return showDialog(
    context: context,
    barrierDismissible: !isSaving, // evita cerrar mientras guarda
    builder: (dialogCtx) {
      final List<Widget> dialogActions = [];

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
            onPressed: isSaving ? null : () => Navigator.pop(dialogCtx),
            child: Text(cancelLabel),
          ),
        );
      }

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
          onPressed: isSaving
              ? null
              : () async {
                  try {
                    isSaving = true;
                    // Forzar rebuild para deshabilitar botones
                    (dialogCtx as Element).markNeedsBuild();
                    await onSave();
                    if (Navigator.canPop(dialogCtx)) {
                      Navigator.pop(dialogCtx);
                    }
                  } catch (e) {
                    // Mostrar error sin cerrar el diálogo
                    if (ScaffoldMessenger.maybeOf(context) != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  } finally {
                    isSaving = false;
                    if (dialogCtx.mounted) {
                      (dialogCtx as Element).markNeedsBuild();
                    }
                  }
                },
          child: isSaving
              ? SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(colors.onPrimaryContainer),
                  ),
                )
              : Text(saveLabel),
        ),
      );

      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
    },
  );
}
