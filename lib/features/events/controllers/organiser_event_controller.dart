import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_community/data/repositories/event/event_repository.dart';
import 'package:elderly_community/data/repositories/event_category/event_category_repository.dart';
import 'package:elderly_community/data/repositories/user/user_repository.dart';
import 'package:elderly_community/features/events/models/event_model.dart';
import 'package:elderly_community/features/events/models/location_model.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interval_time_picker/interval_time_picker.dart';
import 'package:interval_time_picker/models/visible_step.dart';
import 'package:uuid/uuid.dart';

import '../../../data/repositories/notification/notification_repository.dart';
import '../../../data/services/notification/fcm_service.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../../notification/models/notification_model.dart';
import '../models/event_category_model.dart';

class OrganiserEventController extends GetxController {
  static OrganiserEventController get instance => Get.find();

  final eventRepository = Get.put(EventRepository());

  GlobalKey<FormState> eventFormKey = GlobalKey<FormState>();
  final title = TextEditingController();
  final description = TextEditingController();
  final organizationId = TextEditingController();
  final maxParticipants = TextEditingController();
  final address = TextEditingController();
  var latitude = '';
  var longitude = '';
  Rxn<DateTime> startDateTime = Rxn<DateTime>();
  Rxn<DateTime> endDateTime = Rxn<DateTime>();
  final GoogleMapApi = dotenv.env['GOOGLE_MAP_API_KEY'];
  String sessionToken = Uuid().v4();
  final RxList<EventCategoryModel> eventCategories = <EventCategoryModel>[].obs;
  final RxList<EventCategoryModel> selectedCategories =
      <EventCategoryModel>[].obs;

  // List<File> images = [];
  var images = <File>[].obs;

  // var selectedImage = Rx<File?>(null); // Observable for selected image
  var pickedFile;

  /// Validation Messages
  final RxBool startDateTimeError = false.obs;
  final RxBool endDateTimeError = false.obs;

  final RxList<EventModel> eventList = <EventModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchEvents(OrganiserEventStatus eventType) async {
    try {
      isLoading.value = true;
      final events;
      switch (eventType) {
        case OrganiserEventStatus.pending:
          events = await eventRepository.fetchEventsByStatus(
              OrganiserEventStatus.pending.toString().split('.').last,
              organizerId: UserController.instance.user.value.id);
          break;
        case OrganiserEventStatus.upcoming:
          events = await eventRepository.fetchUpcomingEvents(
              organizerId: UserController.instance.user.value.id);
          print(events);
          break;
        case OrganiserEventStatus.past:
          events = await eventRepository.fetchPastEvents(
              organizerId: UserController.instance.user.value.id);
          break;
        case OrganiserEventStatus.rejected:
          events = await eventRepository.fetchEventsByStatus(
              OrganiserEventStatus.rejected.toString().split('.').last,
              organizerId: UserController.instance.user.value.id);
          break;
      }

      eventList.assignAll(events!);
    } catch (e) {
      ECLoaders.errorSnackBar(
          title: 'Error', message: 'Error fetching events: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void loadEventData(EventModel event) {
    title.text = event.title;
    description.text = event.description;
    startDateTime.value = event.startDateTime.toDate();
    endDateTime.value = event.endDateTime.toDate();
    organizationId.text = event.organizationId;
    maxParticipants.text = event.maxParticipants.toString();
    // location.text = event.location;
    // latitude = event.latitude;
    // longitude = event.longitude;
    images.addAll(event.images.map((path) => File(path)).toList());
  }

  void generateNewSessionToken() {
    sessionToken = Uuid().v4();
    print("session token: " + sessionToken);
  }

  // Date Picker
  Future<void> pickDateTime(bool isStart) async {
    if (!isStart && startDateTime.value == null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text('Please select a start date & time first'),
        ),
      );
      return;
    }

    DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: isStart ? DateTime.now() : startDateTime.value,
      firstDate: isStart ? DateTime.now() : (startDateTime.value!),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showIntervalTimePicker(
        context: Get.context!,
        initialTime:
            ECHelperFunctions.roundToNearestFiveMinutes(TimeOfDay.now()),
        interval: 5,
        visibleStep: VisibleStep.fifths,
      );

      if (pickedTime != null) {
        DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (isStart) {
          startDateTime.value = selectedDateTime;
          startDateTimeError.value = false;

          // Clear previous endDateTime if it’s earlier
          if (endDateTime.value != null &&
              endDateTime.value!.isBefore(startDateTime.value!)) {
            endDateTime.value = null;
            endDateTimeError.value = true;
          }
        } else {
          if (selectedDateTime.isBefore(startDateTime.value!)) {
            ScaffoldMessenger.of(Get.context!).showSnackBar(
              SnackBar(
                content:
                    Text('End Date & Time must be after Start Date & Time'),
              ),
            );
            // Get.snackbar(
            //     "Error", "End Date & Time must be after Start Date & Time");
            return;
          }

          endDateTime.value = selectedDateTime;
          endDateTimeError.value = false;
        }
      }
    }
  }

  Future<void> pickImage() async {
    pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      images.add(File(pickedFile.path));
    }
  }

  void clearFields() {
    title.clear();
    description.clear();
    startDateTime.value = null;
    endDateTime.value = null;
    organizationId.clear();
    maxParticipants.clear();
    address.clear();
    images.clear();
    startDateTimeError.value = false;
    endDateTimeError.value = false;
    selectedCategories.value = [];
  }

  void fetchEventCategories() async {
    try {
      final categoryRepository = Get.put(EventCategoryRepository());
      final categories = await categoryRepository.fetchAvailableEventCategory();

      eventCategories.assignAll(categories!);
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  bool validateFields() {
    bool isValid = true;
    if (startDateTime.value == null) {
      startDateTimeError.value = true;
      isValid = false;
    }
    if (endDateTime.value == null) {
      endDateTimeError.value = true;
      isValid = false;
    }
    return isValid;
  }

  // Handle Form Submission
  void submitForm() async {
    try {
      // Start loading
      ECFullScreenLoader.openLoadingDialog(
          'We are submitting your event proposal', ECImages.docerAnimation);

      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECFullScreenLoader.stopLoading();
        ECLoaders.errorSnackBar(title: "Error", message: 'No internet connection');
        return;
      }

      // Validate fields
      bool fieldsValid = validateFields();
      bool formValid = eventFormKey.currentState!.validate();
      if (!formValid || !fieldsValid) {
        ECFullScreenLoader.stopLoading();
        return;
      }

      // Validate Images
      if (images.isEmpty) {
        ECLoaders.errorSnackBar(
            title: 'Error', message: "Please select at least one image.");
        return;
      }

      // Upload images to Firebase Storage
      List<String> imageUrls =
          await eventRepository.uploadImages("Events_Posters", images);

      final location = LocationModel(
        address: address.text,
        latitude: double.parse(latitude),
        longitude: double.parse(longitude),
      );

      final List<String> categoryIds = selectedCategories
          .map((category) => category.id)
          .whereType<String>() // Remove nulls
          .toList();

      final event = EventModel(
        title: title.text,
        description: description.text,
        startDateTime: Timestamp.fromDate(startDateTime.value!.toUtc()),
        endDateTime: Timestamp.fromDate(endDateTime.value!.toUtc()),
        organizationId: UserController.instance.user.value.id,
        categoryIds: categoryIds,
        location: location,
        maxParticipants: int.parse(maxParticipants.text),
        registrations: [],
        status: OrganiserEventStatus.pending.toString().split('.').last,
        images: imageUrls,
        createdAt: Timestamp.now(),
      );

      await eventRepository.saveEvent(event);

      // fetchEvents();
      ECFullScreenLoader.stopLoading();

      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: "Success", message: "Event added successfully!");
      });
    } catch (e) {
      ECFullScreenLoader.stopLoading();
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> collectFeedback(EventModel event) async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(title: 'Error', message: 'No internet connection.');
        return;
      }
      await eventRepository.collectFeedback(event.id!);

      await sendNotificationToRegisteredUsers(
          event.registrations, event.id!, event.title);

      ECLoaders.successSnackBar(
          title: "Success", message: "Sent Feedback Form!");
    } catch (e) {
      ECLoaders.errorSnackBar(title: "Error", message: e.toString());
    }
  }

  Future<void> sendNotificationToRegisteredUsers(
      List<String> registrations, String eventId, String eventTitle) async {
    try {
      if (registrations.isEmpty) {
        ECLoaders.errorSnackBar(
          title: "No Registrations",
          message: "No users have registered for this event.",
        );
        return;
      }

      // Loop through registered users and send notifications
      for (String userId in registrations) {
        String? userToken =
            await UserRepository.instance.getUserDeviceToken(userId);

        if (userToken != null && userToken.isNotEmpty) {
          NotificationModel feedbackNotification = NotificationModel(
            userId: userId,
            title: "📅 $eventTitle Feedback",
            body: "Don't forget to fill in the event feedback form!",
            createdAt: Timestamp.now(),
            type: NotificationType.eventFeedback,
            data: {
              'eventId': eventId,
              'eventTitle': eventTitle,
            },
            read: false,
          );

          final notificationRepo = NotificationRepository.instance;
          await notificationRepo.saveNotification(feedbackNotification);

          // Send FCM push notification
          await FcmService.sendNotification(
            token: userToken,
            title: "📅 $eventTitle Feedback",
            body: "Don't forget to fill in the event feedback form!",
            data: {
              'type': 'eventFeedback',
              'eventId': eventId,
              'eventTitle': eventTitle,
              'userId': userId,
            },
          );
        }
      }
    } catch (e) {
      ECLoaders.errorSnackBar(
        title: "Error Sending Notifications",
        message: e.toString(),
      );
    }
  }
}
