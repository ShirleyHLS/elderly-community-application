import 'dart:io';

import 'package:elderly_community/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../utils/helpers/network_manager.dart';
import '../models/ai_chat_model.dart';

class AiChatController extends GetxController {
  var messages = <AIChatModel>[].obs;
  var textController = TextEditingController();
  final selectedImage = Rx<File?>(null);
  RxBool isLoading = false.obs;
  ScrollController scrollController = ScrollController();

  late stt.SpeechToText speech;
  RxBool isListening = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeChat();
    speech = stt.SpeechToText();
  }

  void _initializeChat() {
    messages.addAll([
      AIChatModel(
          text:
              'Hello there! I\'m here to chat with you anytime.\nAsk me anything, share your thoughts, or just say hi!',
          isUser: false),
    ]);
  }

  Future<void> callGeminiModel() async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ECLoaders.errorSnackBar(
            title: 'Error', message: 'No Internet Connection');
        return;
      }

      if (textController.text.isEmpty && selectedImage.value == null) {
        ECLoaders.warningSnackBar(
            title: 'Warning',
            message: 'Please enter a message or select an image.');
        return;
      }

      messages.add(AIChatModel(
        text: textController.text,
        isUser: true,
        imagePath: selectedImage.value?.path,
      ));
      isLoading.value = true;

      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: dotenv.env['GOOGLE_GEMINI_API_KEY']!,
      );

      final List<Content> contents = [];

      if (selectedImage.value != null) {
        final imageBytes = await selectedImage.value!.readAsBytes();
        contents.add(
          Content.multi(
            [
              DataPart('image/jpeg', imageBytes),
              TextPart(textController.text.trim()),
            ],
          ),
        );
      } else {
        contents.add(Content.text(textController.text.trim()));
      }

      final response = await model.generateContent(contents);
      print(response);

      messages.add(AIChatModel(text: response.text!, isUser: false));
      isLoading.value = false;

      textController.clear();
      selectedImage.value = null;

      // Scroll to the bottom after adding a message
      Future.delayed(Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    var pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }

  void removeSelectedImage() {
    selectedImage.value = null;
  }

  Future<void> requestMicrophonePermission() async {
    if (await Permission.microphone.request().isGranted) {
      // Start recording or listening
      startListening();
    } else {
      ECLoaders.errorSnackBar(
          title: 'Permission Denied',
          message: 'Microphone permission is required to record audio.');
    }
  }

  Future<void> startListening() async {
    bool available = await speech.initialize();
    if (available) {
      isListening.value = true;
      final options = stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
      );
      speech.listen(
        onResult: (result) {
          textController.text = result.recognizedWords;
          print(
              'Recognized: ${result.recognizedWords}, Final: ${result.finalResult}');
          if (result.finalResult) {
            print('Final transcription: ${result.recognizedWords}');
          }
        },
        listenOptions: options,
      );
    }
  }

  Future<void> stopListening() async {
    await speech.stop();
    await Future.delayed(
        Duration(milliseconds: 500)); // ensure final result is processed
    isListening.value = false;
    if (textController.text.trim().isNotEmpty) {
      callGeminiModel(); // Immediately send after speaking
    } else {
      ECLoaders.warningSnackBar(
        title: 'No Input',
        message: 'No speech detected. Please try again.',
      );
    }
  }

  void cancelListening() {
    speech.stop();
    isListening.value = false;
    textController.clear();
  }
}
