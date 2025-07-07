import 'package:flutter/material.dart';

class SearchFilterBar extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterPressed;

  const SearchFilterBar({
    super.key,
    required this.onSearchChanged,
    required this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          /// Search Bar
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(width: 3),

          /// Filter Button
          IconButton(
            icon: const Icon(Icons.filter_list, size: 28),
            onPressed: onFilterPressed,
          ),
        ],
      ),
    );
  }
}
