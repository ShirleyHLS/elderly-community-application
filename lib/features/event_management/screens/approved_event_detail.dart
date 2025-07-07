import 'package:flutter/material.dart';
import 'package:elderly_community/features/event_management/controllers/event_management_controller.dart';
import 'package:elderly_community/features/events/models/event_model.dart';
import '../../../common/curved_app_bar.dart';
import '../../../common/event_detail_widget.dart';
import '../../../utils/constants/colors.dart';

class ApprovedEventDetailScreen extends StatelessWidget {
  const ApprovedEventDetailScreen({super.key, required this.event});

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final controller = EventManagementController.instance;

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Text("Approved Event"),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            /// Event Details
            Expanded(
              child: SingleChildScrollView(
                child: EventDetailWidget(event: event),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.green[100],
                border: Border.all(color: Colors.green, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8.0),
                  Text(
                    "APPROVED",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
