import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'ml_service.dart'; // 确保你之前创建了此文件
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

void main() => runApp(const MaterialApp(home: EmotiSocialV2()));

class EmotiSocialV2 extends StatefulWidget {
  const EmotiSocialV2({super.key});
  @override
  State<EmotiSocialV2> createState() => _EmotiSocialV2State();
}

class _EmotiSocialV2State extends State<EmotiSocialV2> {
  @override
  void initState() {
    super.initState();
    // 提前触发模型下载，防止拍照时由于下载模型导致主线程卡死（Signal 3 崩溃）
    _warmupML();
  }

  // 建议封装一个小方法，防止 File('') 报错影响后续逻辑
  Future<void> _warmupML() async {
    try {
      // 只是为了触发 ML Kit 的模型下载机制
      await MLService.recognizeText(File('dummy.path'));
    } catch (_) {
      // 忽略 File 不存在的报错，我们的目的只是为了“摸”一下 TextRecognizer
    }
  }

  File? _image;
  String _resultText = "等待识别...";

  Future<void> _handleAction(bool isTextMode) async {
    final picker = ImagePicker();
    // 自动处理你当年 BitmapUtils 里的缩放逻辑
    final pickedFile = await picker.pickImage(source: ImageSource.camera, maxWidth: 800);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _image = file;
        _resultText = "正在分析中...";
      });

      if (isTextMode) {
        final text = await MLService.recognizeText(file);
        setState(() => _resultText = "识别文本：\n$text");
      } else {
        final count = await MLService.detectFaces(file);
        setState(() => _resultText = "检测到 $count 张人脸");
      }
    }
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EmotiSocial v2')),
      body: Column(
        children: [
          if (_image != null)
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(_image!, fit: BoxFit.contain),
              ),
            )
          else
            const Expanded(
              flex: 1,
              child: Center(child: Icon(Icons.image_outlined, size: 80, color: Colors.grey)),
            ),
          const Divider(height: 1),
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: SelectableText(
                _resultText,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
          ),
          // 底部留白，给悬浮按钮腾位置
          const SizedBox(height: 70), 
        ],
      ),
      
      // 🌟 这就是你要的旋转 45 度加号菜单
      floatingActionButton: SpeedDial(
        icon: Icons.add, // 默认是加号
        activeIcon: Icons.add, // 激活时还是加号，但我们会让它旋转
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        activeBackgroundColor: Colors.red, // 展开时变红色
        // 关键：旋转动画，45度旋转（对应你当年的交互）
        animationCurve: Curves.easeInOut,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.face),
            label: '人脸检测',
            onTap: () => _handleAction(false),
          ),
          SpeedDialChild(
            child: const Icon(Icons.text_fields),
            label: '文字识别',
            onTap: () => _handleAction(true),
          ),
        ],
      ),
    );
  }
}