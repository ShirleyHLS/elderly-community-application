import 'dart:convert';

import 'package:elderly_community/data/repositories/event/event_repository.dart';
import 'package:elderly_community/features/events/models/event_model.dart';
import 'package:elderly_community/utils/local_storage/storage_utility.dart';
import 'package:elderly_community/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class FavoriteEventRepository extends GetxController {
  static FavoriteEventRepository get instance => Get.find();

  static const String _favKey = 'favorite_events';
  final RxMap<String, bool> favourites = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFavorites();
  }

  void _loadFavorites() {
    final favList = ECLocalStorage.instance().readData(_favKey);
    if (favList != null) {
      final storedFavorites = jsonDecode(favList) as Map<String, dynamic>;
      favourites.assignAll(
          storedFavorites.map((key, value) => MapEntry(key, value as bool)));
    }
    // favourites.assignAll({for (var id in favList) id.toString(): true});
  }

  // Get favorite event IDs
  // static List<String> getFavoriteEvents() {
  //   final data = localStorage.read<List<dynamic>>(_favKey);
  //   return data != null ? List<String>.from(data) : [];
  // }

  // Add event to favorites
  // static void addFavorite(String eventId) {
  //   final favorites = getFavoriteEvents();
  //   if (!favorites.contains(eventId)) {
  //     favorites.add(eventId);
  //     localStorage.write(_favKey, favorites);
  //     ECLoaders.customToast(message: 'Event has been added to the Favourite.');
  //   }
  // }

  // Remove event from favorites
  // static void removeFavorite(String eventId) {
  //   final favorites = getFavoriteEvents();
  //   if (favorites.contains(eventId)) {
  //     favorites.remove(eventId);
  //     localStorage.write(_favKey, favorites);
  //     ECLoaders.customToast(
  //         message: 'Event has been removed from the Favourite.');
  //   }
  // }

  // Check if event is favorite
  bool isFavorite(String eventId) {
    return favourites[eventId] ?? false;
  }

  void toggleFavourite(String eventId) {
    if (!favourites.containsKey(eventId)) {
      favourites[eventId] = true;
      saveFavouritesToStorage();
      ECLoaders.customToast(message: 'Event has been added to the Favourite.');
    } else {
      ECLocalStorage.instance().removeData(eventId);
      favourites.remove(eventId);
      saveFavouritesToStorage();
      favourites.refresh();
      ECLoaders.customToast(
          message: 'Event has been removed from the Favourite.');
    }
  }

  void saveFavouritesToStorage() {
    final encodedFavorites = json.encode(favourites);
    ECLocalStorage.instance().saveData(_favKey, encodedFavorites);
  }

  Future<List<EventModel>?> favoriteEvents() async{
    return EventRepository.instance.getFavouriteEvents(favourites.keys.toList());
  }
}
