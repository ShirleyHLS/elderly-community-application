import 'package:elderly_community/data/repositories/user/user_repository.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:elderly_community/utils/exceptions/firebase_auth_exceptions.dart';
import 'package:elderly_community/utils/exceptions/format_exceptions.dart';
import 'package:elderly_community/utils/exceptions/platform_exceptions.dart';
import 'package:elderly_community/utils/local_storage/storage_utility.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../services/notification/fcm_service.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  /// Variables
  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;
  UserController userController = Get.put(UserController());

  User? get authUser => _auth.currentUser;

  @override
  void onReady() {
    FlutterNativeSplash.remove();
    screenRedirect();
  }

  screenRedirect() async {
    final user = _auth.currentUser;

    print('️❤️❤️' + user.toString());

    if (user != null) {
      // User is signed in
      final userRepository = Get.put(UserRepository());
      // Save device token
      final deviceToken = {
        'deviceToken': await FcmService.instance.getFCMToken(),
      };
      await UserRepository.instance.updateSingleField(deviceToken);
      await ECLocalStorage.init(user.uid);

      userController.user.value = await userRepository.fetchUserDetails();
      final role = userController.user.value.role;

      print('👍👍👍' + role);

      // final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      // if (initialMessage != null) {
      //   print('📲 Launched from notification, skipping default redirect');
      //   return;
      // }

      switch (role) {
        case 'elderly':
          Get.offAllNamed('/elderly_navigation');
          break;
        case 'caregiver':
          Get.offAllNamed('/caregiver_navigation');
          break;
        case 'admin':
          Get.offAllNamed('/admin_navigation');
          break;
        case 'event organiser':
          Get.offAllNamed('/organiser_navigation');
          break;
        default:
          Get.offAllNamed('/login'); // Redirect to login if role is unknown
      }
    } else {
      // No user is signed in
      deviceStorage.writeIfNull('isFirstTime', true);
      deviceStorage.read('isFirstTime') != true
          ? Get.offAllNamed('/login')
          : Get.offAllNamed('/on_boarding');
    }
  }

/* Email & Password sign-in */

  /// Email Authentication - Sign in
  Future<UserCredential> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw ECFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw ECFormatException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw 'Auth: Something went wrong. Please try again';
    }
  }

  /// Email Authentication - Register
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password, String phone) async {
    try {
      final phoneExists = await UserRepository.instance.checkIfPhoneNumberExist(phone);

      if (phoneExists) {
        throw 'Phone number already exists. Please use a different one.';
      }

      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw ECFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw ECFormatException(e.code).message;
    } on FormatException catch (_) {
      throw const ECFormatException();
    } on PlatformException catch (e) {
      throw ECPlatformException(e.code).message;
    } catch (e) {
      throw '$e';
    }
  }

  /// Log out
  Future<void> logOut() async {
    await _auth.signOut();
    Get.offAllNamed('/login');
  }

  Future<UserCredential> createNewAccount(String email, String password) async {
    FirebaseApp tempApp = await Firebase.initializeApp(
        name: "flutter", options: Firebase.app().options);

    return await FirebaseAuth.instanceFor(app: tempApp)
        .createUserWithEmailAndPassword(email: email, password: password);
  }
}
