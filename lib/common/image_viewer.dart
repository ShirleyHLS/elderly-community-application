import 'package:flutter/material.dart';

class ImageViewerScreen extends StatelessWidget {
  final String fileUrl;
  final String title;

  const ImageViewerScreen({super.key, required this.fileUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: InteractiveViewer(
          clipBehavior: Clip.none,
          panEnabled: true,
          child: Image.network(
            fileUrl,
            fit: BoxFit.contain,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              return Text('Failed to load image');
            },
          ),
        ),
      ),
    );
  }
}
