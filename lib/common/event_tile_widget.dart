import 'package:elderly_community/utils/constants/colors.dart';
import 'package:elderly_community/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/repositories/event/favourite_event_local_repository.dart';
import '../features/events/models/event_model.dart';
import '../features/profile/controllers/user_controller.dart';
import 'carousel_image_slider.dart';

class EventTileWidget extends StatelessWidget {
  final VoidCallback onTap;
  final bool showFavoriteButton;
  final EventModel event;

  const EventTileWidget({
    super.key,
    required this.onTap,
    this.showFavoriteButton = false,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final role = UserController.instance.user.value.role;
    FavoriteEventRepository? favouriteController;
    if (role == "elderly" || role == "caregiver") {
      favouriteController = FavoriteEventRepository.instance;
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Carousel Image Slider
                CarouselImageSlider(imageUrls: event.images),
                const SizedBox(height: 12), // Spacing

                /// Event Details
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ECColors.secondary,
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  ECHelperFunctions.formatEventDate(
                      event.startDateTime.toDate(), event.endDateTime.toDate()),
                  style: TextStyle(
                    fontSize: 13,
                    color: ECColors.darkerGrey, // Subtle text color
                  ),
                ),
                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(
                      Icons.location_pin, // Location icon
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location.address,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Show distance
                if (event.distance != null)
                  Text(
                    "${event.distance!.toStringAsFixed(2)} km away",
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
              ],
            ),
          ),
          if (showFavoriteButton)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filledTonal(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                icon: Obx(
                  () {
                    bool isFav = favouriteController!.favourites[event.id] ?? false;
                    return Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.black,
                    );
                  },
                ),
                onPressed: () => favouriteController!.toggleFavourite(event.id!),
              ),
            ),
        ]),
      ),
    );
  }
}
