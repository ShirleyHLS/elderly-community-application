import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_community/features/binding/models/binding_model.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../authentication/authentication_repository.dart';
import '../user/user_repository.dart';

class BindingRepository extends GetxController {
  static BindingRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> saveBindingRequest(BindingModel request) async {
    try {
      DocumentReference docRef =
          await _db.collection("Bindings").add(request.toJson());
      return docRef.id;
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

  Future<List<BindingModel>?> fetchBindings(String role) async {
    try {
      Query query = _db
          .collection("Bindings")
          .where("status", whereIn: ["pending", "approved"]);

      if (role == "caregiver") {
        query = query.where("caregiver_id",
            isEqualTo: AuthenticationRepository.instance.authUser?.uid);
      } else if (role == "elderly") {
        query = query.where("elderly_id",
            isEqualTo: AuthenticationRepository.instance.authUser?.uid);
      }

      final documentSnapshot = await query.get();

      if (documentSnapshot.docs.isNotEmpty) {
        List<BindingModel> bindings = [];

        for (var snapshot in documentSnapshot.docs) {
          BindingModel binding = BindingModel.fromSnapshot(snapshot);

          // Fetch Name
          final userRepository = UserRepository.instance;

          final elderlyData =
              await userRepository.fetchUserDetails(userId: binding.elderlyId);
          final caregiverData = await userRepository.fetchUserDetails(
              userId: binding.caregiverId);

          binding.elderlyName = elderlyData.name ?? 'unknown';
          binding.elderlyProfile = elderlyData.profilePicture ?? '';

          binding.caregiverName = caregiverData.name;
          binding.caregiverProfile = caregiverData.profilePicture ?? '';
          binding.caregiverDeviceToken = caregiverData.deviceToken ?? '';

          bindings.add(binding);
        }
        return bindings;
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

  // Future<List<BindingModel>?> fetchApprovedBindings(String role) async {
  //   try {
  //     final snapshot = await _db
  //         .collection("Bindings")
  //         .where("elderly_id",
  //             isEqualTo: AuthenticationRepository.instance.authUser?.uid)
  //         .where("status", isEqualTo: "approved")
  //         .get();
  //     if (snapshot.docs.isEmpty) return [];
  //
  //     List<Map<String, dynamic>> results = [];
  //
  //     for (var doc in snapshot.docs) {
  //       final binding = BindingModel.fromSnapshot(doc);
  //       final caregiverDetails = await UserRepository.instance.getUserDeviceToken(binding.caregiverId);
  //
  //       if (caregiverDetails != null) {
  //         results.add({
  //           "caregiver_id": binding.caregiverId,
  //           "name": caregiverDetails["name"],
  //           "fcm_token": caregiverDetails["fcm_token"],
  //         });
  //       }
  //     }
  //
  //     return results;
  //     return snapshot.docs.map((doc) => BindingModel.fromSnapshot(doc)).toList();
  //   } on FirebaseException catch (e) {
  //     throw ECFirebaseException(e.code).message;
  //   } on FormatException catch (_) {
  //     throw const ECFormatException();
  //   } on PlatformException catch (e) {
  //     throw ECPlatformException(e.code).message;
  //   } catch (e) {
  //     throw 'Something went wrong. Please try again';
  //   }
  // }

  Future<void> updateSingleField(String id, Map<String, dynamic> json) async {
    try {
      await _db.collection("Bindings").doc(id).update(json);
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

  Future<BindingModel?> getExistingBinding(
      {required String caregiverId, required String elderlyId}) async {
    try {
      final querySnapshot = await _db
          .collection("Bindings")
          .where("caregiver_id", isEqualTo: caregiverId)
          .where("elderly_id", isEqualTo: elderlyId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return BindingModel.fromSnapshot(querySnapshot.docs.first);
      } else {
        return null;
      }
    } catch (e) {
      throw 'Error fetching existing binding: ${e.toString()}';
    }
  }
}
