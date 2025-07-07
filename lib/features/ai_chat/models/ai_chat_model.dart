class AIChatModel {
  final String text;
  final bool isUser;
  final String? imagePath;

  AIChatModel({
    required this.text,
    required this.isUser,
    this.imagePath,
  });
}
