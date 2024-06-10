import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class HomeProvider extends ChangeNotifier {
  Uint8List? imageData;
  TextEditingController textController = TextEditingController();

  bool isLoading = false;
  bool searchChanging = false;

  void loadingUpdate(bool val) {
    isLoading = val;
    notifyListeners();
  }

  void searchUpdate(bool val) {
    searchChanging = val;
    notifyListeners();
  }

  Future<void> textToImage() async {
    String engine_id = "stable-diffusion-v1-6";
    String api_host = 'https://api.stability.ai';
    String api_key = "YOUR-API-KEY";

    final response = await http.post(
      Uri.parse("$api_host/v1/generation/$engine_id/text-to-image"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "image/png",
        "Authorization": "Bearer $api_key"
      },
      body: jsonEncode(
        {
          "text_prompts": [
            {
              "text": textController.text,
              "weight": 1,
            }
          ],
          "cfg_scale": 7,
          "height": 1024,
          "width": 1024,
          "samples": 1,
          "steps": 30,
        },
      ),
    );

    if (response.statusCode == 200) {
      imageData = response.bodyBytes;
      loadingUpdate(false);
      searchUpdate(true);
      notifyListeners();
    } else {
      print(response.statusCode.toString());
    }
  }

  Future<String> _localPath() async {
    final directory = await getApplicationSupportDirectory();
    return directory.path;
  }

  Future<File> _localFile(String filename) async {
    final path = await _localPath();
    return File('$path/$filename');
  }

  Future<File> writeCounter(String filename, String content) async {
    final file = await _localFile(filename);
    return file.writeAsString(content);
  }

  Future<void> saveImageToFile(Uint8List bytes, String filename) async {
    try {
      final path = await _localPath();
      final file = File('$path/$filename');
      await file.writeAsBytes(bytes);
      print('Image saved to $path/$filename');
    } catch (e) {
      print('Failed to save image: $e');
    }
  }
}
