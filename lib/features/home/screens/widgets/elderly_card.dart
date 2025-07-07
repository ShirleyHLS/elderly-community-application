import 'package:cached_network_image/cached_network_image.dart';
import 'package:elderly_community/features/binding/models/binding_model.dart';
import 'package:elderly_community/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ElderlyCard extends StatelessWidget {
  final BindingModel elderly;
  final int index;

  const ElderlyCard({
    super.key,
    required this.elderly,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3),
      child: GestureDetector(
        onTap: () => Get.toNamed('elderly_management', arguments: index),
        child: Card(
          color: ECColors.primary,
          child: ListTile(
            leading: SizedBox(
              width: 40,
              height: 40,
              child: (elderly.elderlyProfile != null &&
                      elderly.elderlyProfile!.isNotEmpty)
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: elderly.elderlyProfile!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                    )
                  : const CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
            ),
            title: Text(elderly.elderlyName!, style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
