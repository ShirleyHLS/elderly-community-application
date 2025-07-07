import 'package:elderly_community/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';
import '../../events/models/event_model.dart';
import '../controllers/feedback_controller.dart';

class FeedbackListScreen extends StatelessWidget {
  const FeedbackListScreen({
    super.key,
    required this.eventId,
  });

  final String eventId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FeedbackController());

    controller.fetchFeedback(eventId);

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Text("Attendee Feedback"),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        return controller.feedbackList.isEmpty
            ? Center(child: Text('No feedback yet.'))
            : Column(
                children: [
                  SizedBox(height: ECSizes.spaceBtwItems),

                  /// Overall Rating Section
                  Center(
                    child: Column(
                      spacing: 3,
                      children: [
                        Text(
                          "Overall Rating",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(controller.overallRating.value.toStringAsFixed(2),
                            style: TextStyle(
                                fontSize: 36, fontWeight: FontWeight.bold)),
                        RatingBarIndicator(
                          rating: controller.overallRating.value,
                          itemBuilder: (context, _) =>
                              Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 30.0,
                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Based on ${controller.totalReviews.value} reviews',
                          style: Theme.of(context).textTheme.labelMedium,
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: ECSizes.spaceBtwSections),

                  Expanded(
                    child: ListView.builder(
                      itemCount: controller.feedbackList.length,
                      itemBuilder: (context, index) {
                        final feedback = controller.feedbackList[index];

                        return ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(feedback.userId,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(width: 5),
                              Text(
                                timeAgo(feedback.createdAt.toDate()),
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: ECSizes.xs),
                              Row(
                                children: [
                                  RatingBarIndicator(
                                    rating: feedback.rating.toDouble(),
                                    itemBuilder: (context, _) =>
                                        Icon(Icons.star, color: Colors.amber),
                                    itemCount: 5,
                                    itemSize: 16.0,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    " (${feedback.rating.toString()})",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              SizedBox(height: ECSizes.xs),
                              Text(
                                feedback.feedback,
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
      }),
    );
  }

  String timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    print(diff.inHours);
    if (diff.inDays >= 1) return "${diff.inDays} days ago";
    if (diff.inHours >= 1) return "${diff.inHours} hours ago";
    return "Just now";
  }
}
