import 'package:elderly_community/features/elderly_management/controllers/elderly_management_controller.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:elderly_community/utils/constants/enums.dart';
import 'package:elderly_community/utils/constants/sizes.dart';
import 'package:elderly_community/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';
import '../../../utils/constants/colors.dart';
import '../controllers/medical_record_controller.dart';

class MedicalRecordListScreen extends StatelessWidget {
  const MedicalRecordListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MedicalRecordController());

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Text(
            UserController.instance.user.value.role == 'caregiver'
                ? "${ElderlyManagementController.instance.elderlyDetail.value.name}'s Medical Records"
                : "Medical Records",),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Filter Buttons
            Wrap(
              spacing: 8.0,
              runSpacing: 3.0,
              children: [
                _buildFilterChip(controller, "All"),
                _buildFilterChip(controller, RecordType.labReport.name),
                _buildFilterChip(controller, RecordType.prescription.name),
                _buildFilterChip(controller, RecordType.invoice.name),
              ],
            ),
            SizedBox(height: ECSizes.spaceBtwItems),

            // List of Records
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }
                if (controller.medicalList.isEmpty) {
                  return Center(child: Text("No medical records found"));
                }

                return RefreshIndicator(
                  onRefresh: () async =>
                      controller.fetchMedicalRecordBasedOnRole(),
                  child: ListView.builder(
                    itemCount: controller.filteredList.length,
                    itemBuilder: (context, index) {
                      final record = controller.filteredList[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => Get.toNamed('medical_record_detail',
                              arguments: record),
                          child: Card(
                            color: Colors.grey[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.only(
                                  left: 10.0,
                                  right: 10.0,
                                  top: 3.0,
                                  bottom: 3.0),
                              leading: SizedBox(
                                width: 40,
                                height: 40,
                                child: Icon(Icons.file_copy),
                              ),
                              title: Text(record.title),
                              subtitle: Text(
                                '${record.recordType} | ${ECHelperFunctions.getFormattedDate(record.createdAt.toDate())}',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('medical_record_form'),
        shape: CircleBorder(),
        backgroundColor: ECColors.primary,
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildFilterChip(MedicalRecordController controller, String label) {
    return Obx(() => ChoiceChip(
          backgroundColor: Colors.white,
          selectedColor: ECColors.secondary,
          label: Text(
            label,
            style: TextStyle(
              color: controller.selectedFilter.value == label
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          selected: controller.selectedFilter.value == label,
          onSelected: (selected) {
            controller.updateFilter(label == "All" ? "" : label);
          },
        ));
  }
}
