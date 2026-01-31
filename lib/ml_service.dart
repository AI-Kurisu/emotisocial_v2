import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';

class MLService {
  // 🌟 使用中文识别器作为主识别器
  static final _textRecognizer = TextRecognizer(script: TextRecognitionScript.chinese);

  static Future<String> recognizeText(File imageFile) async {
    try {
      if (!await imageFile.exists()) return "图片不存在";

      final inputImage = InputImage.fromFile(imageFile);
      
      // Android 15 稳定性缓冲
      await Future.delayed(const Duration(milliseconds: 500));
      
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text.isEmpty ? "未检测到内容" : recognizedText.text;
    } catch (e) {
      print("OCR Error: $e");
      // 如果这里依然报错 ClassNotFound，说明 build.gradle 还没生效
      return "识别失败，请检查模型下载状态";
    }
  }

  static Future<int> detectFaces(File imageFile) async {
    final faceDetector = FaceDetector(options: FaceDetectorOptions());
    try {
      final inputImage = InputImage.fromFile(imageFile);
      await Future.delayed(const Duration(milliseconds: 500));
      final List<Face> faces = await faceDetector.processImage(inputImage);
      return faces.length;
    } finally {
      await faceDetector.close();
    }
  }
}