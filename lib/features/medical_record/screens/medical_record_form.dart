import 'package:elderly_community/features/medical_record/controllers/medical_record_controller.dart';
import 'package:elderly_community/utils/constants/colors.dart';
import 'package:elderly_community/utils/constants/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';
import '../../../common/input_field_widget.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/validators/validation.dart';

class MedicalRecordFormScreen extends StatelessWidget {
  const MedicalRecordFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MedicalRecordController.instance;
    controller.resetForm();

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
          ),
          title: Text('Add Record'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: ECSizes.defaultSpace, vertical: ECSizes.spaceBtwItems),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Upload Button & Selected Files
                    Container(
                      padding: EdgeInsets.all(14),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        color: ECColors.light,
                      ),
                      child: Obx(() => Column(
                            children: [
                              // Display selected files
                              controller.selectedFiles.isNotEmpty
                                  ? Wrap(
                                      spacing: 8,
                                      children:
                                          controller.selectedFiles.map((file) {
                                        bool isImage = file.path
                                                .toLowerCase()
                                                .endsWith('.png') ||
                                            file.path
                                                .toLowerCase()
                                                .endsWith('.jpg') ||
                                            file.path
                                                .toLowerCase()
                                                .endsWith('.jpeg');

                                        return Stack(
                                          alignment: Alignment.topRight,
                                          children: [
                                            Container(
                                              width: 100,
                                              height: 100,
                                              margin: EdgeInsets.only(top: 8),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.grey[200],
                                                image: isImage
                                                    ? DecorationImage(
                                                        image: FileImage(file),
                                                        fit: BoxFit.cover)
                                                    : null,
                                              ),
                                              child: !isImage
                                                  ? Center(
                                                      child: Icon(
                                                          Icons
                                                              .insert_drive_file,
                                                          size: 40,
                                                          color:
                                                              Colors.grey[600]))
                                                  : null,
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.cancel,
                                                  color: Colors.red),
                                              onPressed: () => controller
                                                  .selectedFiles
                                                  .remove(file),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    )
                                  : Text('No files selected.'),

                              SizedBox(height: ECSizes.spaceBtwItems),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: controller.pickFiles,
                                  icon: Icon(Icons.upload),
                                  label: Text('Upload Files or Images'),
                                ),
                              ),
                            ],
                          )),
                    ),
                    const SizedBox(height: ECSizes.spaceBtwItems),
                    Divider(),
                    const SizedBox(height: ECSizes.spaceBtwItems),

                    InputFieldWidget(
                      icon: Icons.title,
                      label: 'Title',
                      child: TextFormField(
                        controller: controller.titleController,
                        validator: (value) =>
                            ECValidator.validateEmptyText('Title', value),
                        decoration: InputDecoration(
                          hintText: 'Enter Title',
                        ),
                      ),
                    ),

                    InputFieldWidget(
                      icon: Icons.category,
                      label: 'Type of Record',
                      child: Obx(() => Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: RecordType.values.map((type) {
                              return GestureDetector(
                                onTap: () =>
                                    controller.selectedRecordType.value = type,
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          controller.selectedRecordType.value ==
                                                  type
                                              ? ECColors.buttonPrimary
                                              : Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        type.icon,
                                        color: controller
                                                    .selectedRecordType.value ==
                                                type
                                            ? ECColors.buttonPrimary
                                            : Colors.black,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        type.name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: controller.selectedRecordType
                                                      .value ==
                                                  type
                                              ? ECColors.buttonPrimary
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )),
                    ),
                    SizedBox(height: ECSizes.spaceBtwInputFields),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.saveRecord,
                child: Text(ECTexts.save),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
