import 'package:elderly_community/features/auth/models/user_model.dart';
import 'package:elderly_community/features/user_management/controllers/user_management_controller.dart';
import 'package:elderly_community/features/user_management/screens/widgets/user_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/curved_app_bar.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/popups/loaders.dart';
import '../../../utils/validators/validation.dart';

class OrganiserFormScreen extends StatelessWidget {
  const OrganiserFormScreen({super.key, this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    final UserManagementController controller =
        UserManagementController.instance;

    if (user != null) {
      controller.setUser(user!);
    } else {
      controller.clearFields();
      controller.role.text = 'event organiser';
    }

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
          ),
          title: Text(user != null ? 'Edit User' : 'New User'),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ECSizes.defaultSpace,
              vertical: ECSizes.spaceBtwItems),
          child: Form(
            key: controller.userFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// Name
                CustomTextField(
                  label: "Organisation Name",
                  controller: controller.name,
                  icon: Icons.person,
                  validator: (value) =>
                      ECValidator.validateEmptyText('Name', value),
                ),
                SizedBox(height: ECSizes.spaceBtwInputFields),

                /// Website
                CustomTextField(
                  label: 'Organisation Website',
                  controller: controller.organisationWebsite,
                  icon: Icons.web,
                  validator: (value) =>
                      ECValidator.validateEmptyText('Website', value),
                ),
                SizedBox(height: ECSizes.spaceBtwInputFields),

                /// Description
                CustomTextField(
                  maxLines: 3,
                  label: 'Organisation Description',
                  controller: controller.organisationDescription,
                  icon: Icons.description,
                  validator: (value) =>
                      ECValidator.validateEmptyText('Description', value),
                ),
                SizedBox(height: ECSizes.spaceBtwInputFields),

                /// Establishment Date
                CustomTextField(
                  label: 'Establishment Date',
                  controller: controller.dobController,
                  icon: Icons.calendar_today,
                  isReadOnly: true,
                  isEnabled: user == null,
                  onTap: () => controller.pickDate(),
                  validator: (value) => ECValidator.validateEmptyText(
                      'Establishment Date', value),
                ),
                SizedBox(height: ECSizes.spaceBtwInputFields),

                /// Email
                CustomTextField(
                  label: ECTexts.email,
                  controller: controller.email,
                  icon: Icons.email,
                  isReadOnly: user != null,
                  isEnabled: user == null,
                  validator: (value) => ECValidator.validateEmail(value),
                ),
                SizedBox(height: ECSizes.spaceBtwInputFields),

                /// Phone number
                CustomTextField(
                  label: ECTexts.phoneNo,
                  controller: controller.phoneNumber,
                  icon: Icons.call,
                  keyboardType: TextInputType.number,
                  validator: (value) => ECValidator.validatePhoneNumber(value),
                ),
                SizedBox(height: ECSizes.spaceBtwInputFields),

                /// Password
                user == null
                    ? Column(
                        children: [
                          CustomTextField(
                            label: ECTexts.password,
                            controller: controller.password,
                            icon: Icons.lock,
                            validator: (value) =>
                                ECValidator.validatePassword(value),
                          ),
                          const SizedBox(height: ECSizes.spaceBtwInputFields),
                        ],
                      )
                    : SizedBox.shrink(),

                /// Role
                CustomTextField(
                  label: 'Role',
                  controller: controller.role,
                  icon: Icons.person_outline,
                  isReadOnly: true,
                  isEnabled: false,
                  validator: (value) =>
                      ECValidator.validateEmptyText('Role', value),
                ),
                SizedBox(height: ECSizes.spaceBtwItems),
                Divider(),
                SizedBox(height: ECSizes.spaceBtwItems),

                Text(
                  "Business Registration Certificate",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: ECSizes.spaceBtwItems),
                if (user != null) ...[
                  user!.businessRegistrationFiles!.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: user!.businessRegistrationFiles?.length,
                          itemBuilder: (context, index) {
                            final fileUrl =
                                user!.businessRegistrationFiles?[index];
                            final fileName =
                                controller.extractFileName(fileUrl!);

                            return GestureDetector(
                              onTap: () => _openFileViewer(fileName, fileUrl),
                              child: Card(
                                color: Colors.grey[100],
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  contentPadding: EdgeInsets.only(
                                    left: 15.0,
                                    right: 5.0,
                                    top: 5.0,
                                    bottom: 5.0,
                                  ),
                                  title: Text(fileName),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.download),
                                    onPressed: () => _openFile(fileUrl),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text("No attachments available"),
                        ),
                ] else ...[
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
                                                        Icons.insert_drive_file,
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
                                : Text(
                                    'Please upload your business registration certificate',
                                    textAlign: TextAlign.center,
                                  ),

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
                ],
                SizedBox(height: ECSizes.spaceBtwSections),
                if (user != null)
                  Center(
                    child: Text(
                      "Status: ${user!.organisationStatus?.toUpperCase()}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: user!.organisationStatus ==
                                OrganisationAccountStatus.approved.name
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                SizedBox(height: ECSizes.spaceBtwSections),

                /// Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () => user != null
                          ? controller.editUser(user!.id.toString(),
                              isOrganiser: true)
                          : controller.addEventOrganiser(),
                      child: const Text(ECTexts.save)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openFile(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ECLoaders.errorSnackBar(title: "Error", message: "Cannot open file");
    }
  }

  void _openFileViewer(String fileName, String fileUrl) {
    String extension = fileName.toLowerCase();

    if (extension.endsWith('.pdf')) {
      // Open in PDF Viewer
      Get.toNamed('pdf_viewer', arguments: {
        'fileUrl': fileUrl,
        'title': 'Business Registration Certificate'
      });
    } else if (extension.endsWith('.jpg') ||
        extension.endsWith('.jpeg') ||
        extension.endsWith('.png')) {
      // Open in Image Viewer
      Get.toNamed('image_viewer', arguments: {
        'fileUrl': fileUrl,
        'title': 'Business Registration Certificate'
      });
    } else {
      // Open in Browser (for DOCX, XLSX, etc.)
      _openFile(fileUrl);
    }
  }
}
