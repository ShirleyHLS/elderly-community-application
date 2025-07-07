import 'dart:io';

import 'package:elderly_community/common/input_field_widget.dart';
import 'package:elderly_community/features/events/models/event_category_model.dart';
import 'package:elderly_community/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:intl/intl.dart';

import '../../../common/curved_app_bar.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/validators/validation.dart';
import '../controllers/organiser_event_controller.dart';

class EventFormScreen extends StatelessWidget {
  const EventFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OrganiserEventController controller =
        OrganiserEventController.instance;

    controller.clearFields();
    controller.fetchEventCategories();

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
          ),
          title: Text('Event Proposal'),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ECSizes.defaultSpace,
              vertical: ECSizes.spaceBtwItems),
          child: Form(
            key: controller.eventFormKey,
            child: Column(
              children: [
                InputFieldWidget(
                  icon: Icons.event,
                  label: 'Event Title',
                  child: TextFormField(
                    controller: controller.title,
                    validator: (value) =>
                        ECValidator.validateEmptyText('Event Title', value),
                    decoration: InputDecoration(
                      hintText: 'Enter Event Title',
                    ),
                  ),
                ),

                InputFieldWidget(
                  icon: Icons.description,
                  label: 'Event Description',
                  child: TextFormField(
                    maxLines: 3,
                    controller: controller.description,
                    validator: (value) => ECValidator.validateEmptyText(
                        'Event Description', value),
                    decoration: InputDecoration(
                      hintText: 'Enter Event Description',
                    ),
                  ),
                ),

                InputFieldWidget(
                  icon: Icons.location_on,
                  label: 'Event Location',
                  child: GooglePlacesAutoCompleteTextFormField(
                    textEditingController: controller.address,
                    googleAPIKey: controller.GoogleMapApi!,
                    debounceTime: 400,
                    // defaults to 600 ms
                    // countries: ["de"], // optional, by default the list is empty (no restrictions)
                    fetchCoordinates: true,
                    minInputLength: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter Event Location',
                    ),
                    validator: (value) =>
                        ECValidator.validateEmptyText('Location', value),
                    overlayContainerBuilder: (child) => Material(
                      elevation: 1.0,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: child,
                    ),
                    onPlaceDetailsWithCoordinatesReceived: (prediction) {
                      // this method will return latlng with place detail
                      controller.latitude = prediction.lat.toString();
                      controller.longitude = prediction.lng.toString();
                      controller.address.text = prediction.description ?? '';
                      print(
                          "Coordinates: (${prediction.lat},${prediction.lng})");
                    },
                    // this callback is called when fetchCoordinates is true
                    onSuggestionClicked: (prediction) {
                      print(prediction.description);
                      controller.address.text = prediction.description!;
                      controller.address.selection = TextSelection.fromPosition(
                        TextPosition(offset: prediction.description!.length),
                      );
                      controller.generateNewSessionToken();
                    },
                    sessionToken: controller.sessionToken,
                  ),
                ),

                InputFieldWidget(
                  icon: Icons.calendar_today,
                  label: 'Start Date & Time',
                  child: Obx(
                    () => GestureDetector(
                      onTap: () => controller.pickDateTime(true),
                      child: Container(
                        width: double.infinity, // Ensure full width
                        padding:
                            EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: controller.startDateTimeError.value
                                  ? ECColors.error
                                  : Colors.grey),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          controller.startDateTime.value != null
                              ? DateFormat('yyyy-MM-dd HH:mm')
                                  .format(controller.startDateTime.value!)
                              : "Select Start Date & Time",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ),

                InputFieldWidget(
                  icon: Icons.calendar_today_outlined,
                  label: 'End Date & Time',
                  child: Obx(
                    () => GestureDetector(
                      onTap: () => controller.pickDateTime(false),
                      child: Container(
                        width: double.infinity, // Ensure full width
                        padding:
                            EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: controller.endDateTimeError.value
                                  ? ECColors.error
                                  : Colors.grey),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          controller.endDateTime.value != null
                              ? DateFormat('yyyy-MM-dd HH:mm')
                                  .format(controller.endDateTime.value!)
                              : "Select End Date & Time",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ),

                InputFieldWidget(
                  icon: Icons.people,
                  label: 'Max Participants',
                  child: TextFormField(
                    controller: controller.maxParticipants,
                    validator: (value) => ECValidator.validateEmptyText(
                        'Max Participants', value),
                    decoration: InputDecoration(
                      hintText: 'Enter Max Participants',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),

                // Event Categories Selection
                InputFieldWidget(
                  icon: Icons.category,
                  label: 'Event Categories (Max 3)',
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<EventCategoryModel>(
                          hint: Text('Select a category'),
                          validator: (selectedCategories){
                            if (controller.selectedCategories.isEmpty){
                              return 'Please select at least one category';
                            }
                          },
                          items: controller.eventCategories.value
                              .map((category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(category.categoryName),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              if (controller.selectedCategories.length >= 3) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Maximum three categories only'),
                                  ),
                                );
                              } else if (!controller.selectedCategories
                                  .contains(value)) {
                                controller.selectedCategories.add(value);
                              }
                            }
                          },
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 2,
                          children: controller.selectedCategories
                              .map(
                                (category) => Chip(
                                  color:
                                      WidgetStateProperty.all(ECColors.primary),
                                  side: BorderSide.none,
                                  label: Text(category.categoryName),
                                  deleteIcon: Icon(Icons.close),
                                  onDeleted: () {
                                    controller.selectedCategories
                                        .remove(category);
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Upload Image Button & Preview
                Container(
                  padding: EdgeInsets.all(14),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    color: ECColors.light,
                  ),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => controller.images.isEmpty
                            ? Text('No image selected.')
                            : SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: controller.images.length,
                                  itemBuilder: (context, index) {
                                    File imageFile = controller.images[index];
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.file(imageFile,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover),
                                    );
                                  },
                                ),
                              ),
                      ),
                      SizedBox(height: ECSizes.spaceBtwItems),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: controller.pickImage,
                          child: Text('Select Images'),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ECSizes.spaceBtwSections),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.submitForm,
                    label: const Text("Submit"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
