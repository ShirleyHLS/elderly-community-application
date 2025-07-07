import 'package:elderly_community/data/repositories/event/favourite_event_local_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';
import '../../../common/event_detail_widget.dart';
import '../../../utils/constants/colors.dart';
import '../../profile/controllers/user_controller.dart';
import '../controllers/participant_event_controller.dart';

class ParticipantEventDetailScreen extends StatelessWidget {
  const ParticipantEventDetailScreen({
    super.key,
    required this.eventId,
  });

  final String eventId;

  @override
  Widget build(BuildContext context) {
    final controller = ParticipantEventController.instance;
    final favouriteController = FavoriteEventRepository.instance;

    // Fetch the event when the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchEventById(eventId);
    });

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: Obx(() {
          final event = controller.selectedEvent.value;
          return AppBar(
            title: Text(event?.title ?? "Loading..."),
            actions: event == null
                ? [] // No actions while loading
                : [
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () {
                        controller.shareEventOnWhatsApp(event);
                      },
                    ),
                    Obx(() {
                      bool isFav =
                          favouriteController.favourites[event.id] ?? false;
                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.black,
                        ),
                        onPressed: () =>
                            favouriteController.toggleFavourite(event.id!),
                      );
                    }),
                  ],
          );
        }),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }
          final event = controller.selectedEvent.value;
          if (event == null) {
            return Center(child: Text("Event not found"));
          }

          final isEventPast =
              event.startDateTime.toDate().isBefore(DateTime.now());
          final canRegister = !isEventPast &&
              event.maxParticipants > event.registrations.length &&
              !event.registrations
                  .contains(UserController.instance.user.value.id);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: EventDetailWidget(event: event),
                ),
              ),
              SizedBox(height: 16),

              /// Get ticket button
              if (!event.registrations
                  .contains(UserController.instance.user.value.id))
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canRegister
                        ? () {
                            Get.defaultDialog(
                              title: "Confirmation",
                              middleText:
                                  "Are you sure you want to participate this event?",
                              textConfirm: "Yes",
                              textCancel: "No",
                              confirmTextColor: Colors.white,
                              cancelTextColor: Colors.black,
                              buttonColor: ECColors.buttonPrimary,
                              onConfirm: () {
                                Get.back();
                                controller.participateInEvent(event);
                              },
                            );
                          }
                        : null,
                    style: Theme.of(context)
                        .elevatedButtonTheme
                        .style
                        ?.copyWith(
                          backgroundColor: canRegister
                              ? WidgetStateProperty.all(ECColors.buttonPrimary)
                              : WidgetStateProperty.all(ECColors.grey),
                          side: WidgetStatePropertyAll(BorderSide(
                              color: canRegister
                                  ? ECColors.buttonPrimary
                                  : ECColors.grey)),
                        ),
                    child: Text(
                      canRegister ? "Get Ticket" : "Not Available",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              canRegister ? Colors.white : ECColors.darkerGrey),
                    ),
                  ),
                ),

              /// Feedback button
              if (event.registrations
                      .contains(UserController.instance.user.value.id) &&
                  event.feedbackCollected! &&
                  !controller.hasSubmittedFeedback.value)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Get.toNamed('/feedback_form', arguments: event),
                    label: Text(
                      "Feedback Form",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 20),
            ],
          );
        }),
      ),
    );
  }
}
