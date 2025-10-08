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

  List<int> _getVisiblePages() {
    const int maxVisible = 5; // Máximo de botones visibles
    int startPage = (currentPage - 2).clamp(1, totalPages);
    int endPage = (currentPage + 2).clamp(1, totalPages);

    if (currentPage <= 3) {
      startPage = 1;
      endPage = totalPages > maxVisible ? maxVisible : totalPages;
    } else if (currentPage >= totalPages - 2) {
      endPage = totalPages;
      startPage =
          totalPages - (maxVisible - 1) > 0 ? totalPages - (maxVisible - 1) : 1;
    }

    return List.generate(endPage - startPage + 1, (i) => startPage + i);
  }

  @override
  Widget build(BuildContext context) {
    final visiblePages = _getVisiblePages();

    return Wrap(
      spacing: 6,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (currentPage > 1)
          _buildButton(
            label: "<",
            onPressed: () => onPageChanged(currentPage - 1),
          ),

        if (!visiblePages.contains(1)) ...[
          _buildButton(label: "1", onPressed: () => onPageChanged(1)),
          const Text("...", style: TextStyle(fontSize: 13)),
        ],

        for (var page in visiblePages)
          _buildButton(
            label: "$page",
            isActive: page == currentPage,
            onPressed: () => onPageChanged(page),
          ),

        if (!visiblePages.contains(totalPages)) ...[
          const Text("...", style: TextStyle(fontSize: 13)),
          _buildButton(
            label: "$totalPages",
            onPressed: () => onPageChanged(totalPages),
          ),
        ],

        if (currentPage < totalPages)
          _buildButton(
            label: ">",
            onPressed: () => onPageChanged(currentPage + 1),
          ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    bool isActive = false,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      width: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isActive ? const Color(0xFFA3B9C5) : const Color(0xFFBED6E3),
          foregroundColor: const Color(0xFF1B194B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.zero,
          elevation: 1,
          minimumSize: const Size(38, 38),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
