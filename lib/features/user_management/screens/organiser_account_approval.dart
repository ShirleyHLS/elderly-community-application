import 'package:elderly_community/utils/constants/enums.dart';
import 'package:elderly_community/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/curved_app_bar.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../features/user_management/controllers/user_management_controller.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/popups/loaders.dart';

class OrganisationAccountApprovalScreen extends StatelessWidget {
  final UserModel organiser;

  const OrganisationAccountApprovalScreen({super.key, required this.organiser});

  @override
  Widget build(BuildContext context) {
    final controller = UserManagementController.instance;

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
          ),
          title: Text('Pending Organisation'),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ECSizes.defaultSpace,
              vertical: ECSizes.spaceBtwItems),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailCard(
                  icon: Icons.business,
                  label: 'Organisation Name',
                  content: organiser.name),
              _buildDetailCard(
                  icon: Icons.web,
                  label: 'Organisation Website',
                  content:
                      organiser.organisationWebsite ?? "No website provided"),
              _buildDetailCard(
                  icon: Icons.description,
                  label: 'Organisation Description',
                  content: organiser.organisationDescription ??
                      "No description provided"),
              _buildDetailCard(
                  icon: Icons.calendar_today,
                  label: 'Establishment Date',
                  content: ECHelperFunctions.getFormattedDate(
                      organiser.dob.toDate())),
              _buildDetailCard(
                  icon: Icons.email,
                  label: 'Organisation Email',
                  content: organiser.email),
              _buildDetailCard(
                  icon: Icons.call,
                  label: 'Organisation Phone Number',
                  content: organiser.phoneNumber),
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
              organiser.businessRegistrationFiles!.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: organiser.businessRegistrationFiles?.length,
                      itemBuilder: (context, index) {
                        final fileUrl =
                            organiser.businessRegistrationFiles?[index];
                        final fileName = controller.extractFileName(fileUrl!);

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
              SizedBox(height: ECSizes.spaceBtwItems),
              if (organiser.organisationStatus ==
                  OrganisationAccountStatus.pending.name) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            controller.rejectOrganiser(organiser.id),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: ECColors.error,
                            side: BorderSide(color: ECColors.error)),
                        child: Text("Reject"),
                      ),
                    ),
                    SizedBox(
                      width: ECSizes.spaceBtwItems,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            controller.approveOrganiser(organiser.id),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: ECColors.success,
                            side: BorderSide(color: ECColors.success)),
                        child: Text("Approve"),
                      ),
                    ),
                  ],
                )
              ] else ...[
                Center(
                  child: Text(
                    "Status: ${organiser.organisationStatus?.toUpperCase()}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: organiser.organisationStatus ==
                              OrganisationAccountStatus.approved.name
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
                SizedBox(height: ECSizes.spaceBtwSections),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.approveOrganiser(organiser.id),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: ECColors.success,
                        side: BorderSide(color: ECColors.success)),
                    child: Text("Approve"),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String content,
  }) {
    return Card(
      color: Colors.grey[100],
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: ECColors.secondary),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    textAlign: TextAlign.justify,
                    content,
                  ),
                ],
              ),
            ),
          ],
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
