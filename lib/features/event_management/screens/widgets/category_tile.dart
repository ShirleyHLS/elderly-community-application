import 'package:cached_network_image/cached_network_image.dart';
import 'package:elderly_community/features/auth/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../utils/constants/colors.dart';

class CategoryTile extends StatelessWidget {
  final String name;
  final bool status;
  final VoidCallback onEdit;

  const CategoryTile({
    super.key,
    required this.name,
    required this.status,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 15.0, right: 5.0),
        title: Row(children: [
          Text(
            name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: 8), // Spacing between text and badge
          if (status) // Show badge only if status is true
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green, // Green for active
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Active',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ]),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: ECColors.buttonPrimary),
          onPressed: onEdit,
        ),
      ),
    );
  }
}
