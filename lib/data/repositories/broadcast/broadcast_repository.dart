import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_community/features/broadcast/models/broadcast_model.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../utils/constants/enums.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';

class BroadcastRepository extends GetxController {
  static BroadcastRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<BroadcastModel>?> fetchBroadcastList() async {
    try {
      final documentSnapshot = await _db
          .collection("Broadcast Messages")
          .orderBy('createdAt', descending: true)
          .get();
      if (documentSnapshot.docs.isNotEmpty) {
        List<BroadcastModel> broadcasts = documentSnapshot.docs
            .map((snapshot) =>
                BroadcastModel.fromMap(snapshot.data(), snapshot.id))
            .toList();
        return broadcasts;
      } else {
        return null;
      }
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

  Future<void> saveBroadcast(BroadcastModel broadcast) async {
    try {
      await _db.collection("Broadcast Messages").doc().set(broadcast.toJson());
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
}
