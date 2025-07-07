import 'package:elderly_community/common/event_tile_widget.dart';
import 'package:elderly_community/data/repositories/event/favourite_event_local_repository.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:elderly_community/utils/constants/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/participant_event_controller.dart';
import '../../models/event_model.dart';

class EventCard extends StatelessWidget {
  final List<EventModel> events;

  EventCard({required this.events, super.key});

  @override
  Widget build(BuildContext context) {
    final role = UserController.instance.user.value.role;

    return Obx(
      () => ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];

          return EventTileWidget(
            onTap: () => role == "elderly" || role == "caregiver"
                ? Get.toNamed('participant_event_details', arguments: event.id)
                : Get.toNamed('organiser_event_details', arguments: event),
            showFavoriteButton: role == "elderly" || role == "caregiver",
            event: event,
          );
        },
      ),
    );
  }
}
