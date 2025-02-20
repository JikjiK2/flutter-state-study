import 'package:flutter/material.dart';
import 'package:flutter_state_mvvm/views/privacy_policy_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController EmailController = TextEditingController();
  final TextEditingController PWController = TextEditingController();
  bool _passwordVisible = true;

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.height;
    final deviceHeight = MediaQuery.of(context).size.width;
    final String Email = EmailController.text;
    final String PW = PWController.text;

    bool isValidEmailFormat(value) {
      return RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(value);
    }

    return GestureDetector(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back), // 뒤로가기 아이콘
            onPressed: () {
              Navigator.pop(context); // 이전 화면으로 돌아가기
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 80),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    "로그인",
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 0.0),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            const Text(
                              "이메일 주소",
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        TextFormField(
                          maxLines: 1,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide:
                                    BorderSide(color: Colors.black, width: 2.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                      color: Color.fromRGBO(125, 125, 125, 0.4),
                                      width: 2.0)),
                              hintText: 'Email',
                              suffixIcon: EmailController.text.length > 0
                                  ? IconButton(
                                      icon: const Icon(Icons.cancel),
                                      color: Colors.grey,
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onPressed: () {
                                        EmailController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null),
                          controller: EmailController,
                          onChanged: (text) {
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 0.0),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Text(
                              "비밀번호",
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        TextFormField(
                          style: const TextStyle(fontFamily: ''),
                          maxLines: 1,
                          keyboardType: TextInputType.visiblePassword,
                          autocorrect: false,
                          obscureText: _passwordVisible,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(
                                  color: Colors.black, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: const BorderSide(
                                    color: Color.fromRGBO(125, 125, 125, 0.4),
                                    width: 2.0)),
                            hintText: 'Password',
                            suffixIcon: IconButton(
                              icon: _passwordVisible
                                  ? Icon(Icons.visibility_off)
                                  : Icon(Icons.visibility),
                              color: Colors.grey,
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onPressed: (() {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              }),
                            ),
                          ),
                          controller: PWController,
                          onChanged: (text) {
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 0.0),
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "로그인",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Container(
                            child: TextButton(
                              child: const Text(
                                "이메일 찾기",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ),
                        Container(
                          height: 25,
                          child: VerticalDivider(
                            thickness: 1.2,
                            color: Color.fromRGBO(0, 0, 0, 0.7),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: TextButton(
                              child: const Text(
                                "비밀번호 찾기",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ),
                        Container(
                          height: 25,
                          child: const VerticalDivider(
                            thickness: 1.2,
                            color: Color.fromRGBO(0, 0, 0, 0.7),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: TextButton(
                              child: const Text(
                                "회원가입",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PrivacyPolicy()),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  // 카카오 로그인 버튼
                  LoginButton(
                    iconPath: 'assets/icons/kakao-svgrepo-com.svg',
                    label: '카카오 로그인',
                    onPressed: () {
                      // 카카오 로그인 로직
                      print('카카오 로그인 클릭');
                    },
                    backColor: 0xFFFEE500,
                    textColor: 0xD9000000,
                  ),
                  const SizedBox(height: 12),
                  // 네이버 로그인 로직
                  LoginButton(
                    iconPath: 'assets/icons/naver-svgrepo-com.svg',
                    label: '네이버 로그인',
                    onPressed: () {
                      print('네이버 로그인 클릭');
                    },
                    backColor: 0xFF03C75A,
                    textColor: 0xFFFFFFFF,
                  ),
                  const SizedBox(height: 12),
                  // 구글 로그인 버튼
                  GoogleLoginButton(
                    iconPath: 'assets/icons/google-svgrepo-com.svg',
                    label: 'Google 로그인',
                    onPressed: () {
                      // 구글 로그인 로직
                      print('구글 로그인 클릭');
                    },
                    backColor: 0xFFFFFFFF,
                    textColor: 0x8A000000,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//toastmessage
showCustom(BuildContext context, String msg) {
  FToast fToast = FToast();
  fToast.init(context);
  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15.0),
      color: const Color.fromRGBO(0, 0, 0, 0.57),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Text(
            msg,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
  fToast.showToast(
    child: toast,
    toastDuration: const Duration(seconds: 3),
    gravity: ToastGravity.BOTTOM,
  );
}

Widget CustomBtn(String text, BuildContext context, Widget nextPage) {
  return ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => nextPage), // 다음 페이지로 이동
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.amber,
      elevation: 10.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.black),
    ),
  );
}

class LoginButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onPressed;
  final int backColor;
  final int textColor;

  const LoginButton(
      {required this.iconPath,
      required this.label,
      required this.onPressed,
      required this.backColor,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        splashFactory: NoSplash.splashFactory,
        minimumSize: Size(250.0, 40.0),
        backgroundColor: Color(backColor),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            height: 18.0, // 아이콘 크기 조절
            width: 18.0,
          ),
          const SizedBox(width: 8.0),
          Text(
            label,
            style: TextStyle(
                fontSize: 14.0,
                color: Color(textColor),
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class GoogleLoginButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onPressed;
  final int backColor;
  final int textColor;

  const GoogleLoginButton(
      {required this.iconPath,
      required this.label,
      required this.onPressed,
      required this.backColor,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        splashFactory: NoSplash.splashFactory,
        minimumSize: Size(250.0, 40.0),
        backgroundColor: Color(backColor),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            height: 18.0, // 아이콘 크기 조절
            width: 18.0,
          ),
          const SizedBox(width: 8.0),
          Text(
            label,
            style: TextStyle(
                fontSize: 14.0,
                color: Color(textColor),
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
