import 'package:elderly_community/features/events/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/curved_app_bar.dart';
import '../../../common/input_field_widget.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/validators/validation.dart';
import '../controllers/feedback_controller.dart';

class FeedbackFormScreen extends StatelessWidget {
  const FeedbackFormScreen({
    super.key,
    required this.event,
  });

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final FeedbackController controller = Get.put(FeedbackController());

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
          ),
          title: Text('Event Feedback Form'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: ECSizes.defaultSpace),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: controller.feedbackFormKey,
                  child: Column(
                    children: [
                      Text(
                          "Please share your feedback regarding the event (${event.title})."),
                      SizedBox(height: ECSizes.spaceBtwItems),
                      Divider(),
                      SizedBox(height: ECSizes.spaceBtwItems),
                      InputFieldWidget(
                        icon: Icons.star_rate_rounded,
                        label: 'Rate your overall satisfaction with the event',
                        child: Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(5, (index) {
                              return IconButton(
                                icon: Icon(
                                  index < controller.selectedRating.value
                                      ? Icons.star_rate_rounded
                                      : Icons.star_border_rounded,
                                  color: Colors.orange,
                                  size: 30,
                                ),
                                onPressed: () {
                                  controller.selectedRating.value = index + 1;
                                },
                              );
                            }),
                          ),
                        ),
                      ),
                      InputFieldWidget(
                        icon: Icons.comment,
                        label: 'Suggestions for Improvement',
                        child: TextFormField(
                          maxLines: 5,
                          controller: controller.commentController,
                          validator: (value) => ECValidator.validateEmptyText(
                              'Suggestions', value),
                          decoration: InputDecoration(
                            hintText: 'Enter your suggestions',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ), // Submit Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () => controller.submitFeedback(
                          event.id!, event.organizationId),
                  child: controller.isSubmitting.value
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(ECTexts.submit),
                ),
              ),
            ),
            SizedBox(height: ECSizes.spaceBtwItems),
          ],
        ),
      ),
    );
  }
}
