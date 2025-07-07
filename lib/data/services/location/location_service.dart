import 'package:elderly_community/features/events/models/event_model.dart';
import 'package:elderly_community/utils/popups/loaders.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position?> initialiseLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check and request location permission
    permission = await Geolocator.checkPermission();
    print('Current Permission Status: $permission');
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print('Requested Permission Status: $permission');
    }

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('Location Service Enabled: $serviceEnabled');
    if (!serviceEnabled) {
      print("Location services are disabled.");
      // bool userEnabled = await Geolocator.openAppSettings();
      // if (!userEnabled) {
      ECLoaders.warningSnackBar(
          title: 'Warning', message: 'Location services must be enabled.');
      // return null;
      // }
    }

    // Get current position
    return await Geolocator.getCurrentPosition();
  }

  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || !serviceEnabled) {
      return null;
    }
    return await Geolocator.getCurrentPosition();
  }

  static Future<List<EventModel>> sortEventBasedOnCurrentLocation(
      List<EventModel> events) async {
    Position userLocation = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    // Calculate distance and update event models
    for (var event in events) {
      event.distance = Geolocator.distanceBetween(
            userLocation.latitude,
            userLocation.longitude,
            event.location.latitude,
            event.location.longitude,
          ) /
          1000; // Convert meters to km
    }

    // Sort events by distance (nearest first)
    events.sort((a, b) => a.distance!.compareTo(b.distance!));

    return events;
  }
}
