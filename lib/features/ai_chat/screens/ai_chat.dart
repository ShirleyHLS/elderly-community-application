import 'dart:io';

import 'package:elderly_community/features/ai_chat/controllers/ai_chat_controller.dart';
import 'package:elderly_community/features/ai_chat/screens/widgets/chat_bubble.dart';
import 'package:elderly_community/utils/constants/image_strings.dart';
import 'package:elderly_community/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';

class AIChatScreen extends StatelessWidget {
  const AIChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AiChatController chatController = Get.put(AiChatController());

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Row(children: [
            Image(
                width: 20,
                height: 20,
                fit: BoxFit.contain,
                image: AssetImage(ECImages.gemini)),
            SizedBox(width: 10),
            Text("Gemini Chat")
          ]),
        ),
      ),
      body: Column(children: [
        /// Chat
        Expanded(
          child: Obx(() => ListView.builder(
                controller: chatController.scrollController,
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  final message = chatController.messages[index];
                  return ChatBubble(message: message);
                },
              )),
        ),

        /// User input
        Container(
          margin: EdgeInsets.all(ECSizes.sm),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                File? imageFile = chatController.selectedImage.value;
                if (imageFile == null) return const SizedBox();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 22),
                      child: Stack(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            imageFile,
                            height: 150,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () =>
                                chatController.selectedImage.value = null,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withAlpha(100),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              }),
              Obx(() {
                final isListening = chatController.isListening.value;
                final isLoading = chatController.isLoading.value;

                return Row(
                  children: [
                    if (isListening)
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => chatController.cancelListening(),
                      ),
                    if (isListening)
                      Expanded(
                        child: Text('Listening...'),
                      ),
                    if (!isListening)
                      Expanded(
                        child: TextField(
                          controller: chatController.textController,
                          decoration: InputDecoration(
                            hintText: "Write your message",
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                    if (!isListening)
                      IconButton(
                        icon: const Icon(Icons.image),
                        onPressed: () => chatController.pickImage(),
                      ),
                    if (!isListening)
                      IconButton(
                        icon: Icon(Icons.mic),
                        onPressed: () =>
                            chatController.requestMicrophonePermission(),
                      ),
                    if (isLoading)
                      const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    if (isListening)
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => chatController.stopListening(),
                      ),
                    if (!isListening && !isLoading)
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => chatController.callGeminiModel(),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ]),
    );
  }
}
