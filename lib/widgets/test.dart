import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {

  static const platform = MethodChannel('com.example.camera/intent');
  String? imagePath;
  Future<String?> _openCamera() async {
    try {
      await platform.invokeMethod('openCamera');
    } on PlatformException catch (e) {
      print("카메라 열기 실패: '${e.message}'.");
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler((call) async {
      if (call.method == "imageCaptured") {
        setState(() {
          imagePath = call.arguments; // 이미지 경로를 저장
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Camera")),
      body: Center(
        child: Column(
          children: <Widget>[
            imagePath == null ? const Text("아무것도 없다")  : Text(imagePath!),
            if(imagePath!=null)
              Image.file(File(imagePath!)),
            ElevatedButton(
              onPressed: _openCamera,
              child: const Text("카메라 열기"),
            ),
          ],
        ),
      ),
    );
  }
}
