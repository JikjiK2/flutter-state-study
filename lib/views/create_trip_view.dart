import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addTrip(String destination, DateTime date) {
  CollectionReference trips = FirebaseFirestore.instance.collection("trips");
  final user = <String, dynamic>{
    "destination": "부산",
    "date": DateTime.now(),
  };
  return trips.add(user).then((doc) =>
      print('DocumentSnapshot added with ID: ${doc.id}'))
      .catchError((error) => print("여행 추가 실패: $error"));
}

class CreateTripView extends StatefulWidget {
  const CreateTripView({super.key});

  @override
  State<CreateTripView> createState() => _CreateTripViewState();
}

class _CreateTripViewState extends State<CreateTripView> {
  bool _isExpanded = true;
  bool _isDayExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: const Text(
          'data',
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
            icon: const Icon(Icons.file_upload_outlined),
            color: Colors.black,
            onPressed: () {
              // 프로필 아이콘 클릭 시 동작
              print('공유 아이콘 클릭됨');
            },
          ),
          IconButton(
            icon: const Icon(Icons.map_outlined),
            color: Colors.black,
            onPressed: () {
              // 프로필 아이콘 클릭 시 동작
              print('지도 아이콘 클릭됨');
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            color: Colors.black,
            onPressed: () {
              addTrip('부산',DateTime.now());
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
                  height: 20.0,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            '부산 여행',
                            style: TextStyle(
                                fontSize: 30.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 3.0,
                          ),
                          Column(
                            children: [
                              const SizedBox(
                                height: 12.0,
                              ),
                              Text(
                                '편집',
                                style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        children: [
                          Text(
                            '2024.12.17 - 12.19',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        children: [
                          Text(
                            '이 여행의 스타일을 선택해주세요.',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: const BoxDecoration(color: Colors.grey),
                  width: double.infinity,
                  height: _isExpanded ? 250 : 0,
                  alignment: Alignment.center,
                  // child: KakaoMap(),
                  child: const Text('지도'),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded; // 상태 반전
                      print("터치");
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                    // width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.scale(
                          scaleY: 1.2,
                          scaleX: 2,
                          child: Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.grey.shade400,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text(
                              'day1',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18.0),
                            ),
                            const SizedBox(width: 5.0),
                            Text(
                              '12.17/화',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade500,
                                  fontSize: 18.0),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                setState(() {
                                  _isDayExpanded = !_isDayExpanded; // 상태 반전
                                  print("day 터치");
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 5.0),
                                // width: double.infinity,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Transform.scale(
                                      scale: 1.0,
                                      child: Icon(
                                        _isDayExpanded
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: const BoxDecoration(color: Colors.grey),
                          width: double.infinity,
                          height: 200.0,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 15.0),
                            child: Text('셀프패키지'),
                          ),
                        ),
                        const SizedBox(height: 15.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  splashFactory: NoSplash.splashFactory,
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(color: Colors.grey.shade400, width: 1.3)
                                  ),
                                ),
                                child: const Text('장소 추가', style: TextStyle(fontWeight: FontWeight.bold),),
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  splashFactory: NoSplash.splashFactory,
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(color: Colors.grey.shade400, width: 1.3)
                                  ),
                                ),
                                child: const Text('메모 추가', style: TextStyle(fontWeight: FontWeight.bold),),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
