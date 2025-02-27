import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final bool _isExpanded = true;
  final bool _isDayExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: const Text(
          '프로필',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // 뒤로가기 아이콘
          onPressed: () {
            Navigator.pop(context); // 이전 화면으로 돌아가기
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            color: Colors.black,
            onPressed: () {
              // 프로필 아이콘 클릭 시 동작
              print('체크 아이콘 클릭됨');
            },
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100.0),
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 250.0,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        // backgroundImage: NetworkImage(profileImageUrl),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text("사용자 이름"),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text("ex) 이메일 주소"),
                    ],
                  ),
                ),
                Container(
                  color: Colors.grey.shade400,
                  height: 200.0,
                  width: double.infinity,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Text("여행 기록", style: TextStyle(fontSize: 23.0),),
                        ],),
                        SizedBox(
                          height: 15.0,
                        ),
                        Text(" - 여행지 1", style: TextStyle(fontSize: 16.0),),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(" - 여행지 2", style: TextStyle(fontSize: 16.0),),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(" - 여행지 3", style: TextStyle(fontSize: 16.0),),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.grey.shade500,
                  height: 170.0,
                  width: double.infinity,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("즐겨찾기", style: TextStyle(fontSize: 23.0),),
                          ],),
                        SizedBox(
                          height: 15.0,
                        ),
                        Text(" - 즐겨찾기 1", style: TextStyle(fontSize: 16.0),),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(" - 즐겨찾기 2", style: TextStyle(fontSize: 16.0),),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.grey.shade600,
                  height: 200.0,
                  width: double.infinity,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("여행 계획", style: TextStyle(fontSize: 23.0),),
                          ],),
                        SizedBox(
                          height: 15.0,
                        ),
                        Text(" - 계획된 여행 1", style: TextStyle(fontSize: 16.0),),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(" - 계획된 여행 2", style: TextStyle(fontSize: 16.0),),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(" - 계획된 여행 3", style: TextStyle(fontSize: 16.0),),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
