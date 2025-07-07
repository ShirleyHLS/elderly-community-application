import 'package:elderly_community/data/repositories/event/favourite_event_local_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';
import '../../../common/event_tile_widget.dart';

class ParticipantFavoriteScreen extends StatelessWidget {
  const ParticipantFavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favouriteController = FavoriteEventRepository.instance;

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Text("Wishlist"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Obx(
          () => FutureBuilder(
            future: favouriteController.favoriteEvents(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No favorite events yet."));
              } else {
                final favoriteEvents = snapshot.data!;
                return ListView.builder(
                  itemCount: favoriteEvents.length,
                  itemBuilder: (context, index) {
                    final event = favoriteEvents[index];

                    return EventTileWidget(
                      event: event,
                      onTap: () {
                        Get.toNamed('participant_event_details', arguments: event.id);
                      },
                      showFavoriteButton: true, // Allow removing from favorites
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
