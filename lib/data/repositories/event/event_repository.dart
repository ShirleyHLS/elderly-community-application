import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_community/data/repositories/user/user_repository.dart';
import 'package:elderly_community/features/events/models/event_model.dart';
import 'package:elderly_community/utils/constants/enums.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../features/events/models/event_bar_data_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../authentication/authentication_repository.dart';

class EventRepository extends GetxController {
  static EventRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Function to save event to Firebase
  Future<void> saveEvent(EventModel event) async {
    try {
      await _db.collection("Events").doc().set(event.toJson());
    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<List<String>> uploadImages(String path, List<File> images) async {
    try {
      List<String> downloadUrls = [];
      for (File image in images) {
        String fileName = Uuid().v4();
        Reference ref =
            FirebaseStorage.instance.ref(path).child("$fileName.jpg");
        await ref.putFile(image);
        String downloadUrl = await ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }
      return downloadUrls;
    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<List<EventModel>?> fetchEventsByStatus(String eventStatus,
      {String? organizerId}) async {
    try {
      var query =
          _db.collection("Events").where("status", isEqualTo: eventStatus);

      if (organizerId != null) {
        query = query.where("organizationId", isEqualTo: organizerId);
      }
      if (eventStatus == AdminEventStatus.approved.toString().split('.').last){
        query = query.orderBy("startDateTime", descending: true);
      }

      final documentSnapshot = await query.get();

      List<EventModel> events = [];

      for (var snapshot in documentSnapshot.docs) {
        EventModel event = EventModel.fromSnapshot(snapshot);

        // Fetch Organization Name
        final userRepository = UserRepository.instance;
        String? organizationName =
            await userRepository.getOrganizationName(event.organizationId);
        event.organizationName =
            organizationName ?? "Unknown"; // Add to event model

        events.add(event);
      }
      return events;
    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<List<EventModel>?> getFavouriteEvents(List<String> eventIds) async {
    try {
      final documentSnapshot = await _db
          .collection("Events")
          .where(FieldPath.documentId, whereIn: eventIds)
          .where("status", isEqualTo: 'approved')
          .get();

      List<EventModel> events = [];

      for (var snapshot in documentSnapshot.docs) {
        EventModel event = EventModel.fromSnapshot(snapshot);

        // Fetch Organization Name
        final userRepository = UserRepository.instance;
        String? organizationName =
            await userRepository.getOrganizationName(event.organizationId);
        event.organizationName =
            organizationName ?? "Unknown"; // Add to event model

        events.add(event);
      }
      return events;
    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<List<EventModel>?> fetchUpcomingEvents({String? organizerId}) async {
    try {
      var query = _db
          .collection("Events")
          .where("status", isEqualTo: "approved")
          .where('startDateTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()));

      if (organizerId != null) {
        query = query.where("organizationId", isEqualTo: organizerId);
      }

      final documentSnapshot = await query.get();

      List<EventModel> events = [];

      for (var snapshot in documentSnapshot.docs) {
        EventModel event = EventModel.fromSnapshot(snapshot);

        // Fetch Organization Name
        final userRepository = UserRepository.instance;
        String? organizationName =
            await userRepository.getOrganizationName(event.organizationId);
        event.organizationName =
            organizationName ?? "Unknown"; // Add to event model

        events.add(event);
      }
      return events;
    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<List<EventModel>?> fetchPastEvents(
      {String? organizerId, String? elderlyId}) async {
    try {
      var query = _db
          .collection("Events")
          .where("status", isEqualTo: "approved")
          .where('startDateTime',
              isLessThan: Timestamp.fromDate(DateTime.now()))
          .orderBy("startDateTime", descending: true);

      if (organizerId != null) {
        query = query.where("organizationId", isEqualTo: organizerId);
      }

      if (elderlyId != null) {
        query = query.where("registrations", arrayContains: elderlyId);
      }

      final documentSnapshot = await query.get();

      List<EventModel> events = [];

      for (var snapshot in documentSnapshot.docs) {
        EventModel event = EventModel.fromSnapshot(snapshot);

        // Fetch Organization Name
        final userRepository = UserRepository.instance;
        String? organizationName =
            await userRepository.getOrganizationName(event.organizationId);
        event.organizationName =
            organizationName ?? "Unknown"; // Add to event model

        events.add(event);
      }
      return events;
    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<List<EventModel>?> fetchMyTickets({String? elderlyId}) async {
    try {
      var query = _db
          .collection("Events")
          .where("status", isEqualTo: "approved")
          .orderBy("startDateTime", descending: true);

      if (elderlyId != null) {
        query = query.where("registrations", arrayContains: elderlyId);
      }

      final documentSnapshot = await query.get();

      List<EventModel> events = [];

      for (var snapshot in documentSnapshot.docs) {
        EventModel event = EventModel.fromSnapshot(snapshot);

        // Fetch Organization Name
        final userRepository = UserRepository.instance;
        String? organizationName =
            await userRepository.getOrganizationName(event.organizationId);
        event.organizationName =
            organizationName ?? "Unknown"; // Add to event model

        events.add(event);
      }
      return events;
    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<EventModel?> fetchEventById(String eventId) async {
    try {
      var documentSnapshot = await _db.collection("Events").doc(eventId).get();

      if (!documentSnapshot.exists) {
        return null;
      }

      EventModel event = EventModel.fromSnapshot(documentSnapshot);

      // Fetch Organization Name
      final userRepository = UserRepository.instance;
      String? organizationName =
          await userRepository.getOrganizationName(event.organizationId);
      event.organizationName =
          organizationName ?? "Unknown"; // Add to event model

      return event;
    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<List<EventData>> fetchEventChartData({String? organizerId}) async {
    try {
      var query = _db
          .collection("Events")
          .where("status", isEqualTo: "approved")
          .where('startDateTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()));

      if (organizerId != null) {
        query = query.where("organizationId", isEqualTo: organizerId);
      }

      final documentSnapshot = await query.get();

      List<EventData> eventDataList = [];

      for (var snapshot in documentSnapshot.docs) {
        EventModel event = EventModel.fromSnapshot(snapshot);

        // Convert to EventData for BarChart
        eventDataList.add(EventData(
          eventName: event.title,
          maxParticipants: event.maxParticipants,
          actualParticipants: event.registrations.length, // Count registrations
        ));
      }
      return eventDataList;
    } catch (e) {
      throw 'Error fetching events: $e';
    }
  }

  Future<Map<String, dynamic>> fetchEventStatistics(String organizerId) async {
    try {
      final querySnapshot = await _db
          .collection('Events')
          .where('organizationId', isEqualTo: organizerId)
          .get();

      int totalEvents = querySnapshot.docs.length;
      int totalAttendees = querySnapshot.docs
          .fold(0, (sum, doc) => (doc['registrations'].length ?? 0) + sum);

      return {
        'totalEvents': totalEvents,
        'totalAttendees': totalAttendees,
      };
    } catch (e) {
      throw Exception("Failed to fetch statistics: $e");
    }
  }

  Future<void> participateEvent(String eventId) async {
    try {
      await _db.collection('Events').doc(eventId).update({
        'registrations': FieldValue.arrayUnion(
            [AuthenticationRepository.instance.authUser?.uid]),
      });
    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<void> collectFeedback(String eventId) async {
    try {
      await _db.collection('Events').doc(eventId).update({
        'feedbackCollected': true,
      });
    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Function to update any field in specific reminders collection in Firestore
  Future<void> updateSingleField(
      String eventId, Map<String, dynamic> json) async {
    try {
      await _db.collection("Events").doc(eventId).update(json);
    } on FirebaseException catch (e) {
      throw ECFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Future<Map<String, int>> fetchEventCountByDay(String organisationId) async {
  //   Map<String, int> eventCounts = {};
  //
  //   try {
  //     var snapshot = await _db
  //         .collection('Events')
  //         .where('organizationId', isEqualTo: organisationId)
  //         .get();
  //
  //     for (var doc in snapshot.docs) {
  //       Timestamp startTime = doc['startDateTime'];
  //       String day = "${startTime.toDate().day}"; // Extract day
  //
  //       eventCounts[day] = (eventCounts[day] ?? 0) + 1;
  //     }
  //   } catch (e) {
  //     print("Error fetching daily event counts: $e");
  //   }
  //
  //   return eventCounts;
  // }
  //
  // Future<Map<String, int>> fetchEventCountByMonth(String organisationId) async {
  //   Map<String, int> eventCounts = {};
  //
  //   try {
  //     var snapshot = await _db
  //         .collection('Events')
  //         .where('organizationId', isEqualTo: organisationId)
  //         .get();
  //
  //     for (var doc in snapshot.docs) {
  //       Timestamp startTime = doc['startDateTime'];
  //       String month = "${startTime.toDate().month}"; // Extract month
  //
  //       eventCounts[month] = (eventCounts[month] ?? 0) + 1;
  //     }
  //   } catch (e) {
  //     print("Error fetching monthly event counts: $e");
  //   }
  //
  //   return eventCounts;
  // }
  //
  // Future<Map<String, int>> fetchEventCountByYear(String organisationId) async {
  //   Map<String, int> eventCounts = {};
  //
  //   try {
  //     var snapshot = await _db
  //         .collection('Events')
  //         .where('organizationId', isEqualTo: organisationId)
  //         .get();
  //
  //     for (var doc in snapshot.docs) {
  //       Timestamp startTime = doc['startDateTime'];
  //       String year = "${startTime.toDate().year}"; // Extract year
  //
  //       eventCounts[year] = (eventCounts[year] ?? 0) + 1;
  //     }
  //   } catch (e) {
  //     print("Error fetching yearly event counts: $e");
  //   }
  //
  //   return eventCounts;
  // }

  Future<Map<String, dynamic>> fetchEventCounts() async {
    // Map<String, int> dailyCounts = {};
    Map<String, int> monthlyCounts = {};
    Map<String, int> yearlyCounts = {};
    List<EventModel> todayEvents = [];

    try {
      var snapshot = await _db
          .collection('Events')
          .get();

      for (var doc in snapshot.docs) {
        Timestamp startTime = doc['startDateTime'];
        DateTime eventDate = startTime.toDate();

        final now = DateTime.now();
        final isToday = eventDate.year == now.year &&
            eventDate.month == now.month &&
            eventDate.day == now.day;
        final isApproved = doc['status'] == AdminEventStatus.approved.name;
        if (isToday && isApproved) {
          todayEvents.add(EventModel.fromSnapshot(doc));
        }

        // Count by day
        // String dayKey = "${eventDate.year}-${eventDate.month}-${eventDate.day}";
        // dailyCounts[dayKey] = (dailyCounts[dayKey] ?? 0) + 1;

        // Count by month
        String monthKey = "${eventDate.year}-${eventDate.month}";
        monthlyCounts[monthKey] = (monthlyCounts[monthKey] ?? 0) + 1;

        // Count by year
        String yearKey = "${eventDate.year}";
        yearlyCounts[yearKey] = (yearlyCounts[yearKey] ?? 0) + 1;
      }
    } catch (e) {
      print("Error fetching event statistics: $e");
    }

    return {
      // "dailyCounts": dailyCounts,
      "todayEvents": todayEvents,
      "monthlyCounts": monthlyCounts,
      "yearlyCounts": yearlyCounts,
    };
  }
}
