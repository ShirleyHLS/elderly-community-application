import 'package:elderly_community/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../controllers/event_management_controller.dart';

class EventListView extends StatelessWidget {
  final AdminEventStatus eventStatus;

  EventListView({
    required this.eventStatus,
    super.key,
  });

  final controller = EventManagementController.instance;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.eventList.isEmpty) {
        return const Center(child: Text("No events available"));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: controller.eventList.length,
        itemBuilder: (context, index) {
          final event = controller.eventList[index];

          return Card(
            color: Colors.grey[50],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text(event.title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.schedule),
                    SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        ECHelperFunctions.formatEventDate(
                            event.startDateTime.toDate(),
                            event.endDateTime.toDate()),
                        style: const TextStyle(color: Colors.black54),
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ]),
                  Row(
                    children: [
                      Icon(Icons.business_center_outlined),
                      SizedBox(width: 5),
                      Text(event.organizationName ?? 'unknown',
                          style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                event.status == 'pending'
                    ? Get.toNamed('admin_event_approval', arguments: event)
                    : Get.toNamed('admin_approved_event_detail',
                        arguments: event);
              },
            ),
          );
        },
      );
    });
  }
}
