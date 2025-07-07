import 'package:elderly_community/features/broadcast/models/broadcast_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';
import '../../../common/input_field_widget.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../controllers/admin_broadcast_controller.dart';

class AdminBroadcastDetailScreen extends StatelessWidget {
  const AdminBroadcastDetailScreen({
    super.key,
    required this.notice,
  });

  final BroadcastModel notice;

  @override
  Widget build(BuildContext context) {
    final controller = AdminBroadcastController.instance;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCreatorName(notice.createdBy);
    });

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
          ),
          title: Text('Broadcast Details'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailCard(
              icon: Icons.title,
              label: 'Notice Title',
              content: notice.title,
            ),
            _buildDetailCard(
              icon: Icons.message,
              label: 'Message',
              content: notice.body,
            ),
            _buildRecipientsSection(notice.roles),
            Card(
              color: Colors.grey[100],
              elevation: 2,
              margin: EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.person, color: ECColors.secondary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Created By',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Obx(() => Text(
                                controller.creatorName.value,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildDetailCard(
              icon: Icons.access_time,
              label: 'Created At',
              content: ECHelperFunctions.getFormattedDate(
                  notice.createdAt.toDate(),
                  format: "dd MMM yyyy hh:mm a"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String content,
  }) {
    return Card(
      color: Colors.grey[100],
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: ECColors.secondary),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    textAlign: TextAlign.justify,
                    content,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientsSection(List<String> roles) {
    return Card(
      color: Colors.grey[100],
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.call_received, color: ECColors.secondary),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recipients',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Wrap(
                    spacing: 10,
                    runSpacing: 1,
                    children: roles.map((role) {
                      return Chip(
                        padding: EdgeInsets.all(3),
                        label: Text(
                          role.toUpperCase(),
                        ),
                        backgroundColor: ECColors.primary,
                        side: BorderSide(color: Colors.transparent),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
