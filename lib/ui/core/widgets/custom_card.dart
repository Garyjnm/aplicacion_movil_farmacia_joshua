import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget? child;
  final String? title;
  final String? subtitle; // single-line subtitle
  final List<String>? bodyLines; // additional lines below subtitle
  final List<Widget>? actions; // trailing action icons/buttons
  final EdgeInsetsGeometry? contentPadding;

  const CustomCard({
    super.key,
    this.child,
    this.title,
    this.subtitle,
    this.bodyLines,
    this.actions,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final cardTheme = Theme.of(context).cardTheme;

    final cardColor = cardTheme.color ?? colors.surface;
    final cardElevation = cardTheme.elevation ?? 2.0;

    // If a custom child was passed, render directly (backward compatibility).
    if (child != null && title == null) {
      return Card(
        color: cardColor,
        elevation: cardElevation,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: child,
        ),
      );
    }

    final fonts = Theme.of(context).textTheme;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Card(
      color: cardColor,
      elevation: cardElevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: contentPadding ?? const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: fonts.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: fonts.bodyMedium?.copyWith(
                        fontWeight: FontWeight.normal,
                        color: textColor.withOpacity(0.85),
                      ),
                    ),
                  ],
                  if (bodyLines != null && bodyLines!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    for (final line in bodyLines!)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          line,
                          style: fonts.bodySmall?.copyWith(
                            color: textColor.withOpacity(0.80),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            if (actions != null && actions!.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: actions!,
              ),
          ],
        ),
      ),
    );
  }
}
