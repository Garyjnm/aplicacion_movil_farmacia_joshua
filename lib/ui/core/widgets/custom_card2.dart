import 'package:flutter/material.dart';

/// Card reutilizable para ítems de detalle.
/// Por defecto usa el color del tema; puedes forzar blanco con alwaysWhite:true.
class CustomCard2 extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final GestureTapCallback? onTap;

  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry? contentPadding;
  final double elevation;

  /// Si true fuerza fondo blanco; si false sigue el tema.
  final bool alwaysWhite;

  /// Color manual (si no null tiene prioridad).
  final Color? backgroundColor;

  final ShapeBorder? shape;

  const CustomCard2({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.contentPadding,
    this.elevation = 2,
    this.alwaysWhite = false, // cambia a true si deseas siempre blanco
    this.backgroundColor,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color bg = backgroundColor ??
        (alwaysWhite
            ? Colors.white
            : (theme.cardTheme.color ??
                theme.colorScheme.surface));

    return Card(
      color: bg,
      surfaceTintColor: Colors.transparent, // evita tintes M3
      elevation: elevation,
      shadowColor: Colors.black26,
      margin: margin,
      shape: shape ??
          (theme.cardTheme.shape ??
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              )),
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        tileColor: bg,
        contentPadding:
            contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}