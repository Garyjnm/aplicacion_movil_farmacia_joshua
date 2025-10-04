import 'package:flutter/material.dart';

class PaginacionControls extends StatelessWidget {
  final int currentPage; // Página actual
  final int totalPages; // Total de páginas
  final Function(int) onPageChanged; // Callback al cambiar de página

  const PaginacionControls({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: List.generate(totalPages, (index) {
        final page = index + 1;
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                currentPage == page ? const Color(0xFFA3B9C5) : const Color(0xFFBED6E3),
            foregroundColor: const Color(0xFF1B194B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onPressed: () => onPageChanged(page),
          child: Text("$page"),
        );
      }),
    );
  }
}
