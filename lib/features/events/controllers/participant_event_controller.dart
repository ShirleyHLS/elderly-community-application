import 'dart:io';

import 'package:elderly_community/data/repositories/event_category/event_category_repository.dart';
import 'package:elderly_community/data/repositories/feedback/feedback_repository.dart';
import 'package:elderly_community/data/repositories/reminder/reminder_repository.dart';
import 'package:elderly_community/features/home/controllers/elderly_home_controller.dart';
import 'package:elderly_community/features/reminders/controllers/reminder_controller.dart';
import 'package:elderly_community/features/reminders/models/reminder_model.dart';
import 'package:elderly_community/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/repositories/event/event_repository.dart';
import '../../../data/repositories/event/favourite_event_local_repository.dart';
import '../../../data/services/location/location_service.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/loaders.dart';
import '../../profile/controllers/user_controller.dart';
import '../models/event_category_model.dart';
import '../models/event_model.dart';

class ParticipantEventController extends GetxController {
  static ParticipantEventController get instance => Get.find();

  final eventRepository = Get.put(EventRepository());
  final favoriteRepository = Get.put(FavoriteEventRepository());

  final RxList<EventModel> upcomingEventList = <EventModel>[].obs;
  final RxList<EventModel> myTicketEventList = <EventModel>[].obs;
  final isLoading = false.obs;
  RxList<EventModel> filteredEvents = <EventModel>[].obs; // Filtered events
  RxList<EventCategoryModel> eventCategories = <EventCategoryModel>[].obs;
  RxList<String> selectedCategories = <String>[].obs;
  RxString searchQuery = ''.obs;

  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  Rx<EventModel?> selectedEvent = Rx<EventModel?>(null);
  var hasSubmittedFeedback = false.obs;

  Future<void> fetchEvents(ElderlyEventStatus eventType,
      {applyFilter = true}) async {
    try {
      isLoading.value = true;
      final events;
      if (eventType == ElderlyEventStatus.upcoming) {
        events = await eventRepository.fetchUpcomingEvents();
      } else {
        events = await eventRepository.fetchMyTickets(
            elderlyId: UserController.instance.user.value.id);
      }

      try {
        // final sortedEvents =
        //     await LocationService.sortEventBasedOnCurrentLocation(events);
        // eventList.assignAll(sortedEvents);
        if (eventType == ElderlyEventStatus.upcoming) {
          final sortedEvents =
              await LocationService.sortEventBasedOnCurrentLocation(events);
          upcomingEventList.assignAll(sortedEvents);
        } else {
          myTicketEventList.assignAll(events);
        }
      } catch (e) {
        // eventList.assignAll(events);
        if (eventType == ElderlyEventStatus.upcoming) {
          upcomingEventList.assignAll(events);
        } else {
          myTicketEventList.assignAll(events);
        }
      }
    } catch (e) {
      ECLoaders.errorSnackBar(
          title: 'Error', message: 'Error fetching events: $e');
    } finally {
      if (applyFilter) {
        applyFilters();
      }
      isLoading.value = false;
    }
  }

  Future<void> fetchEventById(String eventId) async {
    try {
      isLoading.value = true;

      // Check if the event is already in the eventList
      final event = upcomingEventList.firstWhereOrNull((e) => e.id == eventId);
      if (event != null) {
        selectedEvent.value = event;
        await checkUserFeedback(eventId);
      } else {
        // Fetch the event from the repository if not found in the list
        final fetchedEvent = await eventRepository.fetchEventById(eventId);
        if (fetchedEvent != null) {
          selectedEvent.value = fetchedEvent;
          await checkUserFeedback(eventId);
        } else {
          ECLoaders.errorSnackBar(title: 'Error', message: 'Event not found');
        }
      }
    } catch (e) {
      print('😒 Error fetching event: $e');
      ECLoaders.errorSnackBar(
          title: 'Error', message: 'Error fetching event: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkUserFeedback(String eventId) async {
    try {
      final feedbackRepository = Get.put(FeedbackRepository());
      final feedbackSnapshot =
          await feedbackRepository.getFeedbackForUser(eventId);

      hasSubmittedFeedback.value =
          feedbackSnapshot != null && feedbackSnapshot.exists;
    } catch (e) {
      print("Error checking feedback: $e");
    }
  }

  Future<void> participateInEvent(EventModel event) async {
    try {
      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        return;
      }

      if (UserController.instance.user.value.role == "elderly") {
        final reminder = ReminderModel(
            elderlyId: UserController.instance.user.value.id,
            title: 'Event Reminder',
            description: event.title,
            reminderTime: event.startDateTime,
            isRecurring: false);
        final reminderRepo = ReminderRepository();

        await Future.wait([
          eventRepository.participateEvent(event.id!),
          reminderRepo.saveReminder(reminder),
        ]);

        fetchEvents(ElderlyEventStatus.upcoming);
        ReminderController.instance.fetchReminders();
        ElderlyHomeController.instance.fetchTodayReminders();
        await fetchEventById(event.id!);
      } else if (UserController.instance.user.value.role == "caregiver") {
        await eventRepository.participateEvent(event.id!);
        await fetchEvents(ElderlyEventStatus.upcoming);
        await fetchEventById(event.id!);
      }

      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: 'Success',
            message: 'You have registered for ${event.title}');
      });
    } catch (e) {
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Fetch event categories
  void fetchCategories() async {
    List<EventCategoryModel>? categories =
        await EventCategoryRepository().fetchAvailableEventCategory();
    eventCategories.assignAll(categories!);
  }

  // Apply search and filter logic
  void applyFilters() {
    List<EventModel> tempEvents = upcomingEventList;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      tempEvents = tempEvents.where((event) {
        return event.title
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            event.description
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    // Apply category filter
    if (selectedCategories.isNotEmpty) {
      tempEvents = tempEvents.where((event) {
        return event.categoryIds.any((id) => selectedCategories.contains(id));
      }).toList();
    }

    filteredEvents.assignAll(tempEvents);
  }

  // Update search query
  void updateSearch(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  // Update selected categories
  void updateSelectedCategories(List<String> categories) {
    selectedCategories.assignAll(categories);
    applyFilters();
  }

  void shareEventOnWhatsApp(EventModel event) async {
    final message = """
📅 *${event.title}*
📍 Location: ${event.location.address}
🕒 Date: ${ECHelperFunctions.getFormattedDate(event.startDateTime.toDate())}
""";

    try {
      // Download the image from Firebase URL
      final response = await http.get(Uri.parse(event.images.first));
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/event_image.jpg');

      await file.writeAsBytes(response.bodyBytes);

      // Share the image
      await Share.shareXFiles([XFile(file.path)], text: message);
    } catch (e) {
      print("Error sharing event: $e");
    }
  }

  void updatePageIndicator(index) => currentPageIndex.value = index;

  void dotNavigationClick(index) {
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  void nextPage() {
    int nextIndex = currentPageIndex.value + 1;

    if (nextIndex >= upcomingEventList.length) {
      // If at the last event, jump back to first
      pageController.jumpToPage(0);
      currentPageIndex.value = 0;
    } else {
      // Move to the next event
      pageController.jumpToPage(nextIndex);
      currentPageIndex.value = nextIndex;
    }
  }
}
