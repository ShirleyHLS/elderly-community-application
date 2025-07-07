import 'package:elderly_community/features/reminders/screens/widgets/reminder_input_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../common/curved_app_bar.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/validators/validation.dart';
import '../controllers/reminder_controller.dart';
import '../models/reminder_model.dart';

class ReminderFormScreen extends StatelessWidget {
  const ReminderFormScreen({super.key, this.reminder});

  final ReminderModel? reminder;

  @override
  Widget build(BuildContext context) {
    final ReminderController controller = ReminderController.instance;

    // Initialize fields with existing reminder data if provided
    if (reminder != null) {
      controller.title.text = reminder!.title;
      controller.description.text = reminder!.description;
      controller.isRecurring.value = reminder!.isRecurring;
      controller.selectedDateTime.value = reminder!.reminderTime.toDate();
    } else {
      // Reset fields when the page is opened for adding a new reminder
      controller.clearFields();
    }

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
          ),
          title: Text(reminder != null ? 'Edit Reminder' : 'New Reminder'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: ECSizes.defaultSpace, vertical: ECSizes.spaceBtwItems),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: controller.addReminderFormKey,
                  child: Column(
                    children: [
                      /// Title
                      ReminderInputField(
                        icon: Icons.title,
                        label: ECTexts.title,
                        child: TextFormField(
                          controller: controller.title,
                          validator: (value) =>
                              ECValidator.validateEmptyText("Title", value),
                          decoration: const InputDecoration(
                            hintText: "Enter Title",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: ECSizes.spaceBtwInputFields),

                      /// Description
                      ReminderInputField(
                        icon: Icons.description,
                        label: ECTexts.description,
                        child: TextFormField(
                          controller: controller.description,
                          validator: (value) => ECValidator.validateEmptyText(
                              "Description", value),
                          decoration: const InputDecoration(
                            hintText: "Enter description",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: ECSizes.spaceBtwInputFields),

                      /// Toggle for "Is Recurring?"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.repeat, color: ECColors.buttonPrimary),
                              const SizedBox(width: 8),
                              const Text(
                                ECTexts.isRecurring,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ECColors.buttonPrimary,
                                ),
                              ),
                            ],
                          ),
                          Obx(
                            () => Switch(
                              value: controller.isRecurring.value,
                              onChanged: (bool value) {
                                controller.isRecurring.value = value;
                              },
                              activeColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ECSizes.spaceBtwInputFields),

                      /// Date & Time
                      Obx(
                        () => ReminderInputField(
                          icon: Icons.access_time,
                          label: controller.isRecurring.value
                              ? ECTexts.time
                              : ECTexts.dateTime,
                          child: Obx(
                            () => InkWell(
                              onTap: controller.pickDateTime,
                              child: Container(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0),
                                  child: Text(
                                    controller.selectedDateTime.value != null
                                        ? (controller.isRecurring.value
                                            ? DateFormat('hh:mm a').format(
                                                controller
                                                    .selectedDateTime.value!)
                                            : DateFormat('yyyy-MM-dd hh:mm a')
                                                .format(controller
                                                    .selectedDateTime.value!))
                                        : controller.isRecurring.value
                                            ? "Select Time"
                                            : "Select Date & Time",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: !controller.dateTimeError.value
                                          ? Colors.black
                                          : ECColors.error,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: ECSizes.spaceBtwInputFields),
                    ],
                  ),
                ),
              ),
            ),

            /// Fixed Save Button at Bottom
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => reminder != null
                    ? controller.editReminder(
                        reminder!.id.toString()) // Update reminder
                    : controller.addReminder(),
                child: Text(ECTexts.save),
              ),
            ),
            SizedBox(height: ECSizes.spaceBtwItems),
          ],
        ),
      ),
    );
  }
}
