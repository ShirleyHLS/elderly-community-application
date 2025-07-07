import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CarouselImageSlider extends StatelessWidget {
  const CarouselImageSlider({
    super.key,
    required this.imageUrls,
  });

  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        enlargeCenterPage: true,
        // Scale effect for the center image
        autoPlay: imageUrls.length > 1,
        autoPlayInterval: const Duration(seconds: 4),
        viewportFraction: 1.0,
        // Show only one image at a time
        enableInfiniteScroll: imageUrls.length > 1,
        scrollPhysics: imageUrls.length > 1
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
      ),
      items: imageUrls.map((imageUrl) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            imageUrl,
            width: double.infinity,
            // height: 150,
            fit: BoxFit.cover,
          ),
        );
      }).toList(),
    );
  }
}
