import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_community/features/medical_record/models/medical_report_model.dart';
import 'package:elderly_community/utils/constants/enums.dart';
import 'package:elderly_community/utils/popups/loaders.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../data/repositories/medical_record/medical_record_repository.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../elderly_management/controllers/elderly_management_controller.dart';
import '../../profile/controllers/user_controller.dart';

class MedicalRecordController extends GetxController {
  static MedicalRecordController get instance => Get.find();

  var isLoading = false.obs;
  final medicalRecordRepository = Get.put(MedicalRecordRepository());
  final role = UserController.instance.user.value.role;
  final RxList<MedicalReportModel> medicalList = <MedicalReportModel>[].obs;
  final RxList<MedicalReportModel> filteredList = <MedicalReportModel>[].obs;

  var selectedFiles = <File>[].obs;
  var titleController = TextEditingController();
  var selectedRecordType = Rxn<RecordType>();

  var selectedFilter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMedicalRecordBasedOnRole();
  }

  void fetchMedicalRecordBasedOnRole() {
    if (UserController.instance.user.value.role == "elderly") {
      fetchMedicalRecords();
    } else {
      fetchMedicalRecords(
          userId: ElderlyManagementController.instance.elderlyDetail.value.id);
    }
  }

  Future<void> fetchMedicalRecords({String? userId}) async {
    try {
      isLoading(true);
      final records =
          await medicalRecordRepository.fetchMedicalRecords(userId: userId);
      if (records != null) {
        medicalList.assignAll(records);
        filterRecords();
      } else {
        medicalList.clear();
      }
    } catch (e) {
      ECLoaders.errorSnackBar(
          title: 'Error', message: 'Error fetching medical records: $e');
    } finally {
      isLoading(false);
    }
  }

  void filterRecords() {
    if (selectedFilter.value == "All") {
      filteredList.assignAll(medicalList);
    } else {
      filteredList.assignAll(medicalList
          .where((record) => record.recordType == selectedFilter.value)
          .toList());
    }
  }

  void updateFilter(String filter) {
    selectedFilter.value = filter.isEmpty ? "All" : filter;
    filterRecords();
  }

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any, // Allows images and files
    );

    if (result != null) {
      selectedFiles.addAll(result.files.map((file) => File(file.path!)));
    }
  }

  void resetForm() {
    titleController.clear();
    selectedFiles.clear();
    selectedRecordType.value = null;
  }

  Future<void> saveRecord() async {
    if (titleController.text.isEmpty ||
        selectedRecordType.value == null ||
        selectedFiles.isEmpty) {
      ECLoaders.errorSnackBar(
          title: "Error", message: "Please fill all fields");
      return;
    }

    try {
      // Start loading
      ECFullScreenLoader.openLoadingDialog(
          'We are saving the medical record', ECImages.docerAnimation);

      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECFullScreenLoader.stopLoading();
        ECLoaders.errorSnackBar(
            title: 'Error', message: 'No internet conenction.');
        return;
      }

      String elderlyId;
      if (UserController.instance.user.value.role == "elderly") {
        elderlyId = UserController.instance.user.value.id;
      } else {
        elderlyId = ElderlyManagementController.instance.elderlyDetail.value.id;
      }

      List<String> uploadedFileUrls =
          await medicalRecordRepository.uploadFiles(selectedFiles);

      final newRecord = MedicalReportModel(
        elderlyId: elderlyId,
        title: titleController.text.trim(),
        fileUrls: uploadedFileUrls,
        recordType: selectedRecordType.value!.name,
        createdAt: Timestamp.now(),
      );

      await medicalRecordRepository.saveMedicalRecord(newRecord);
      fetchMedicalRecordBasedOnRole();
      ECFullScreenLoader.stopLoading();
      Get.back();

      Future.microtask(() {
        ECLoaders.successSnackBar(
            title: "Success", message: "Medical record saved successfully!");
      });
    } catch (e) {
      ECFullScreenLoader.stopLoading();
      ECLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  String extractFileName(String fileUrl) {
    Uri uri = Uri.parse(fileUrl);
    String path = uri.pathSegments.last; // Get last part of the URL
    String decodedFileName =
        Uri.decodeFull(path).split('?').first; // Decode it (handle %2F)
    if (decodedFileName.contains("/")) {
      decodedFileName = decodedFileName.split("/").last;
    }
    return decodedFileName;
  }
}
