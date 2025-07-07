import 'package:elderly_community/features/event_management/controllers/event_category_management_controller.dart';
import 'package:elderly_community/features/events/controllers/organiser_event_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/services/location/location_map.dart';
import '../features/events/models/event_model.dart';
import '../features/events/screens/widgets/expandable_text.dart';
import '../utils/constants/colors.dart';
import '../utils/helpers/helper_functions.dart';
import '../utils/helpers/map_manager.dart';
import 'carousel_image_slider.dart';

class EventDetailWidget extends StatelessWidget {
  const EventDetailWidget({
    super.key,
    required this.event,
  });

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventCategoryManagementController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Image
        CarouselImageSlider(imageUrls: event.images),
        SizedBox(height: 16),

        /// Title
        Text(
          event.title,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            // color: ECColors.secondary,
          ),
        ),
        Text(
          'Organised by ${event.organizationName}',
          style: Theme.of(context).textTheme.labelMedium,
        ),

        SizedBox(height: 16),

        /// Event Tags
        Row(
          children: [
            Expanded(
              child: FutureBuilder<List<String>>(
                future: controller.fetchCategoryName(event.categoryIds),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading...",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold));
                  } else if (snapshot.hasError) {
                    return Text("Error loading categories",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold));
                  } else {
                    List<String> categories =
                        snapshot.data ?? ["Unknown Category"];
                    return Wrap(
                      spacing: 8.0,
                      runSpacing: 5.0,
                      children: categories.map((category) {
                        return Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                          decoration: BoxDecoration(
                            color: ECColors.primary,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text('# ${category.toUpperCase()}'),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Divider(),
        SizedBox(height: 10),

        Row(
          children: [
            Icon(Icons.schedule, size: 18, color: Colors.black87),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                ECHelperFunctions.formatEventDate(
                    event.startDateTime.toDate(), event.endDateTime.toDate()),
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on, size: 18, color: Colors.black87),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                event.location.address,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        LocationMap(
          address: event.location.address,
          latitude: event.location.latitude,
          longitude: event.location.longitude,
        ),
        SizedBox(height: 16),
        Divider(),
        SizedBox(height: 8),

        /// Description
        Text(
          "About Event",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        ExpandableText(text: event.description),
        SizedBox(height: 8),

        if (event.registrations.isNotEmpty) ...[
          Text(
            "Ongoing",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "${event.registrations.length} participant${event.registrations.length > 1 ? 's' : ''}",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        SizedBox(height: 20),
      ],
    );
  }
}
