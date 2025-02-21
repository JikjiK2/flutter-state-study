import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/model/image_picker_model.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/viewModel(Provider)/image_picker_provider.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/view/image_picker_view.dart';
import 'package:flutter_state_mvvm/views/post/post_create_view.dart';
import 'package:flutter_state_mvvm/views/destination_list_view.dart';
import 'package:flutter_state_mvvm/views/home_view.dart';
import 'package:flutter_state_mvvm/views/post/post_list_view.dart';
import 'package:flutter_state_mvvm/views/privacy_policy_view.dart';
import 'package:flutter_state_mvvm/widgets/image_picker.dart';
import 'package:flutter_state_mvvm/widgets/test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'views/splash_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/*Future<void> requestLocationPermission() async {
  var status = await Permission.location.status;
  if(!status.isGranted) {
    await Permission.location.request();
  }
}*/

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);


  runApp(ChangeNotifierProvider(create: (context) {
    final model = ImagePickerModel(); // ImagePickerModel 생성
    final viewModel = ImagePickerViewModel(model); // ImagePickerModel 주입
    return viewModel;
  },child: const MyApp(),));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_test',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('en', ''),
        Locale('ko', ''),
      ],
      theme: ThemeData(
        primaryColor: Colors.black, // 기본 색상
        hintColor: Colors.white, // 강조 색상
        scaffoldBackgroundColor: Colors.white, // 배경색
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.black, // 버튼 배경색
          textTheme: ButtonTextTheme.primary, // 버튼 텍스트 색상
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black), // 기본 텍스트 색상
          bodyMedium: TextStyle(color: Colors.black),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // 앱바 배경색
          titleTextStyle: TextStyle(color: Colors.white), // 앱바 제목 텍스트 색상
        ),
        bottomNavigationBarTheme:
          const BottomNavigationBarThemeData(backgroundColor: Color(0xAA9C55F6),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          unselectedLabelStyle: TextStyle(color: Colors.grey)),

      ),
      home: const ImagePickerView(),
    );
  }
}
