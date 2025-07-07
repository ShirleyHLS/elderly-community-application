import 'package:elderly_community/features/medical_record/controllers/medical_record_controller.dart';
import 'package:elderly_community/features/medical_record/models/medical_report_model.dart';
import 'package:elderly_community/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/curved_app_bar.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class MedicalRecordDetailScreen extends StatelessWidget {
  const MedicalRecordDetailScreen({
    super.key,
    required this.record,
  });

  final MedicalReportModel record;

  @override
  Widget build(BuildContext context) {
    final controller = MedicalRecordController.instance;

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Text("Medical Record"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Record Title
            Text(
              record.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: ECSizes.sm),

            /// Record Type & Date
            Text(
              "${record.recordType} | ${ECHelperFunctions.getFormattedDate(record.createdAt.toDate())}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: ECSizes.sm),
            const Divider(height: 20),
            SizedBox(height: ECSizes.sm),

            /// File Attachments Section
            Text(
              "Attachments",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: ECSizes.spaceBtwItems),

            Expanded(
              child: record.fileUrls.isNotEmpty
                  ? ListView.builder(
                      itemCount: record.fileUrls.length,
                      itemBuilder: (context, index) {
                        final fileUrl = record.fileUrls[index];
                        final fileName = controller.extractFileName(fileUrl);

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
                              leading: Icon(_getFileIcon(fileName), size: 30),
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
            ),
          ],
        ),
      ),
    );
  }

  // Function to identify the file type
  IconData _getFileIcon(String fileName) {
    String extension = fileName.toLowerCase();
    if (extension.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (extension.endsWith('.jpg') ||
        extension.endsWith('.jpeg') ||
        extension.endsWith('.png')) {
      return Icons.image;
    }
    if (extension.endsWith('.doc') || extension.endsWith('.docx')) {
      return Icons.description;
    }
    if (extension.endsWith('.xls') || extension.endsWith('.xlsx')) {
      return Icons.table_chart;
    }
    return Icons.insert_drive_file;
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
        'title': 'Medical Record'
      });
    } else if (extension.endsWith('.jpg') ||
        extension.endsWith('.jpeg') ||
        extension.endsWith('.png')) {
      // Open in Image Viewer
      Get.toNamed('image_viewer',
          arguments: {'fileUrl': fileUrl, 'title': 'Medical Record'});
    } else {
      // Open in Browser (for DOCX, XLSX, etc.)
      _openFile(fileUrl);
    }
  }
}
