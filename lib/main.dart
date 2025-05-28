import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_state_mvvm/views/image_picker_example.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/model/image_picker_model.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/view/captured_full_image_view.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/view/full_image_view.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/view/image_picker.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/view/image_picker_view.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/viewModel(Provider)/image_picker_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(ChangeNotifierProvider(
    create: (context) {
      final model = ImagePickerModel(); // ImagePickerModel 생성
      final viewModel = ImagePickerViewModel(model); // ImagePickerModel 주입
      return viewModel;
    },
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_test',
      initialRoute: '/',
      routes: {
        '/': (context) => const ImagePickerExample(),
        '/imagePickerView': (context) => const ImagePicker(
              selectedColor: Colors.orangeAccent,
              maxSelectableCount: 10,
              showCameraIcon: true,
              removeButtonSize: 20,
              pickerGridCount: 3,
              requestType: "common",
            ),
        '/imagePicker': (context) => const CustomImagePicker(),
        '/fullImage': (context) => const FullScreenImage(),
        '/cameraImage': (context) => const CameraImageView(),
      },
      debugShowCheckedModeBanner: false,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('en', ''),
        Locale('ko', ''),
      ],
      theme: ThemeData(
          primaryColor: Colors.orangeAccent,
          hintColor: Colors.black,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: const ColorScheme.light(
            primary: Colors.black,
            secondary: Colors.white,
            onSecondary: Colors.white,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black), // 기본 텍스트 색상
            bodyMedium: TextStyle(color: Colors.black),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white, // 앱바 배경색
            titleTextStyle: TextStyle(color: Colors.black), // 앱바 제목 텍스트 색상
          ),
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Colors.white,
            contentTextStyle: TextStyle(color: Colors.black),
          )),
      darkTheme: ThemeData(
          primaryColor: Colors.orangeAccent,
          hintColor: Colors.white,
          scaffoldBackgroundColor: Colors.black,
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            secondary: Colors.black,
            onSecondary: Color(0xFF202020),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white), // 기본 텍스트 색상
            bodyMedium: TextStyle(color: Colors.white),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black, // 앱바 배경색
            titleTextStyle: TextStyle(color: Colors.white), // 앱바 제목 텍스트 색상
          ),
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Colors.black,
            contentTextStyle: TextStyle(color: Colors.white),
          )),
    );
  }
}
