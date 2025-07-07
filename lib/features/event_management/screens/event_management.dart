import 'package:elderly_community/features/event_management/screens/widgets/event_list_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../controllers/event_management_controller.dart';

class EventManagementScreen extends StatefulWidget {
  const EventManagementScreen({super.key});

  @override
  State<EventManagementScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventManagementScreen> {
  final EventManagementController controller = Get.put(EventManagementController());
  AdminEventStatus selectedSegment = AdminEventStatus.pending;

  @override
  void initState() {
    super.initState();
    controller.fetchEvent(selectedSegment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Text("Event Management"),
          actions: [
            IconButton(
              onPressed: () => Get.toNamed('admin_event_category_management'),
              icon: Icon(Icons.category),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: CupertinoSlidingSegmentedControl<AdminEventStatus>(
              groupValue: selectedSegment,
              backgroundColor: Colors.grey[200] ?? Colors.grey,
              thumbColor: ECColors.buttonPrimary,
              padding: const EdgeInsets.all(4),
              onValueChanged: (AdminEventStatus? value) {
                if (value != null) {
                  setState(() {
                    selectedSegment = value;
                  });
                }
                controller.fetchEvent(selectedSegment);
              },
              children: <AdminEventStatus, Widget>{
                AdminEventStatus.pending: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "Pending",
                    style: selectedSegment == AdminEventStatus.pending
                        ? TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)
                        : TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                AdminEventStatus.approved: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "Approved",
                    style: selectedSegment == AdminEventStatus.approved
                        ? TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)
                        : TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              },
            ),
          ),
          // Display Event List Based on Selected Segment
          Expanded(
            child: EventListView(
              eventStatus: selectedSegment, // Pass selected event status
            ),
          ),
        ],
      ),
    );
  }
}
