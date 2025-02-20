import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_state_mvvm/views/image_picker_view.dart';
import 'package:flutter_state_mvvm/views/post/post_create_view.dart';
import 'package:flutter_state_mvvm/views/destination_list_view.dart';
import 'package:flutter_state_mvvm/views/home_view.dart';
import 'package:flutter_state_mvvm/views/post/post_list_view.dart';
import 'package:flutter_state_mvvm/views/privacy_policy_view.dart';
import 'package:flutter_state_mvvm/widgets/image_picker.dart';
import 'package:flutter_state_mvvm/widgets/test.dart';
import 'package:permission_handler/permission_handler.dart';
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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.black, // 버튼 배경색
          textTheme: ButtonTextTheme.primary, // 버튼 텍스트 색상
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black), // 기본 텍스트 색상
          bodyMedium: TextStyle(color: Colors.black),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, // 앱바 배경색
          titleTextStyle: TextStyle(color: Colors.white), // 앱바 제목 텍스트 색상
        ),
        bottomNavigationBarTheme:
          const BottomNavigationBarThemeData(backgroundColor: Color(0xAA9C55F6),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          unselectedLabelStyle: TextStyle(color: Colors.grey)),

      ),
      home: ImagePickerView(),
    );
  }
}
