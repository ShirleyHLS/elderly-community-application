import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_community/features/medical_record/models/medical_report_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../authentication/authentication_repository.dart';

class MedicalRecordRepository extends GetxController {
  static MedicalRecordRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<MedicalReportModel>?> fetchMedicalRecords(
      {String? userId}) async {
    try {
      final String uid =
          userId ?? AuthenticationRepository.instance.authUser?.uid ?? '';
      final documentSnapshot = await _db
          .collection("Medical Records")
          .where("elderlyId", isEqualTo: uid)
          .orderBy("createdAt", descending: true)
          .get();
      if (documentSnapshot.docs.isNotEmpty) {
        List<MedicalReportModel> records = documentSnapshot.docs
            .map((snapshot) => MedicalReportModel.fromSnapshot(snapshot))
            .toList();
        return records;
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

  Future<void> saveMedicalRecord(MedicalReportModel report) async {
    try {
      await _db.collection("Medical Records").doc().set(report.toJson());
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

  Future<List<String>> uploadFiles(List<File> files) async {
    try {
      List<String> uploadedFileUrls = [];

      for (var file in files) {
        String fileName = file.path.split('/').last;
        final ref =
            FirebaseStorage.instance.ref("Medical_Records").child(fileName);
        await ref.putFile(file);
        uploadedFileUrls.add(await ref.getDownloadURL());
      }

      return uploadedFileUrls;
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
