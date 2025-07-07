import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class PdfViewerScreen extends StatelessWidget {
  const PdfViewerScreen({
    super.key,
    required this.fileUrl,
    required this.title,
  });

  final String fileUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(title)),
      body: SfPdfViewerTheme(
          data: SfPdfViewerThemeData(
            backgroundColor: Colors.grey[100],
            scrollHeadStyle:
                PdfScrollHeadStyle(backgroundColor: Colors.grey[100]),
          ),
          child: SfPdfViewer.network(fileUrl, canShowScrollHead: true)),
    );
  }
}
