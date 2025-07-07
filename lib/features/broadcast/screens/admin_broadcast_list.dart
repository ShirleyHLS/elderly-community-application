import 'package:elderly_community/features/broadcast/controllers/admin_broadcast_controller.dart';
import 'package:elderly_community/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';
import '../../../utils/constants/colors.dart';

class AdminBroadcastListScreen extends StatelessWidget {
  const AdminBroadcastListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminBroadcastController());

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Broadcast Notice"),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.broadcastList.isEmpty) {
          return Center(child: Text('No broadcast message'));
        }
        return ListView.builder(
          itemCount: controller.broadcastList.length,
          itemBuilder: (context, index) {
            final notice = controller.broadcastList[index];

            return Card(
              color: Colors.grey[100],
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                onTap: ()=> Get.toNamed('admin_broadcast_detail', arguments: notice),
                title: Text(notice.title,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 5,
                      children: [
                        Icon(Icons.campaign),
                        Expanded(
                          child: Text(
                            notice.body,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        Icon(
                          Icons.access_time_outlined,
                        ),
                        Text(ECHelperFunctions.getFormattedDate(
                            notice.createdAt.toDate(),
                            format: "dd MMM yyyy hh:mm a")),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => Get.toNamed('/admin_broadcast_form'),
        backgroundColor: ECColors.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
