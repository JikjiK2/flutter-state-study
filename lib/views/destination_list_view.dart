import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

extension StringExtension on String {
  String insertZwj() {
    return replaceAllMapped(RegExp(r'(\S)(?=\S)'), (m) => '${m[1]}\u200D');
  }
}

class DestinationListView extends StatefulWidget {
  @override
  State<DestinationListView> createState() => _DestinationListViewState();
}

class _DestinationListViewState extends State<DestinationListView> {


  /*void initState(){
    super.initState();
    Future.delayed(Duration(seconds: 2), (){
      setState(() {
        _isLoading = false;
      });
    });
  }*/
  bool _isLoading = false;
  final List<String> tripImages = [
    // SizedBox 대신 사용할 수 있는 더미 데이터
    '여행 사진 1',
    '여행 사진 2',
    '여행 사진 3',
    '여행 사진 4',
    '여행 사진 5',
  ]; // 더미 여행 사진 데이터

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '여행지 목록',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // 뒤로가기 아이콘
          onPressed: () {
            Navigator.pop(context); // 이전 화면으로 돌아가기
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            color: Colors.black,
            onPressed: () {
              // 검색 아이콘 클릭 시 동작
              print('검색 아이콘 클릭됨');
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            color: Colors.black,
            onPressed: () {
              // 프로필 아이콘 클릭 시 동작
              print('프로필 아이콘 클릭됨');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: _isLoading ?
        Skeletonizer(
          child: Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    // 카드 클릭 시 동작
                    print('카드 클릭됨');
                  },
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 25.0, horizontal: 0.0),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                        bottom: BorderSide(
                            width: 10, color: Colors.grey),
                      )),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 여행 사진들
                            Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 400,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal, // 줄 간격
                                      itemCount: tripImages.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 12.0),
                                          child: Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                //24글자 max 추천
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 4.0),
                                                  child: Container(
                                                    width: 200,
                                                    child: Text(
                                                      '겨울 여행 크리스마스 여행 따뜻한 겨울 최고의 겨울'
                                                          .insertZwj(),
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8.0),
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    color: Colors.grey,
                                                    height: 300,
                                                    width: 300,
                                                    child: Text('image'),
                                                  ),
                                                  /*Image.network(
                                                                        tripImages[index],
                                                                        width: 100,
                                                                        fit: BoxFit.cover,
                                                                      ),*/
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // 카드 클릭 시 동작
                    print('카드 클릭됨');
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                        bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      )),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  // backgroundImage: NetworkImage(profileImageUrl),
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'tripTitle',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'userName',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            // 여행 사진들
                            Container(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 4,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ClipRRect(
                                      child: Container(
                                        alignment: Alignment.center,
                                        color: Colors.grey,
                                        height: 100,
                                        width: 100,
                                        child: Text('image'),
                                      ),
                                      /*Image.network(
                                tripImages[index],
                                width: 100,
                                fit: BoxFit.cover,
                              ),*/
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'description',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // 카드 클릭 시 동작
                    print('카드 클릭됨');
                  },
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  // backgroundImage: NetworkImage(profileImageUrl),
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'tripTitle',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'userName',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            // 여행 사진들
                            Container(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 4,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ClipRRect(
                                      child: Container(
                                        alignment: Alignment.center,
                                        color: Colors.grey,
                                        height: 100,
                                        width: 100,
                                        child: Text('image'),
                                      ),
                                      /*Image.network(
                                tripImages[index],
                                width: 100,
                                fit: BoxFit.cover,
                              ),*/
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'description',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ) :
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  // 카드 클릭 시 동작
                  print('카드 클릭됨');
                },
                child: Padding(
                  padding:
                  EdgeInsets.symmetric(vertical: 25.0, horizontal: 0.0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              width: 10, color: Colors.grey.withOpacity(0.3)),
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 여행 사진들
                          Column(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 400,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal, // 줄 간격
                                    itemCount: tripImages.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                        const EdgeInsets.only(right: 12.0),
                                        child: Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              //24글자 max 추천
                                              Padding(
                                                padding:
                                                EdgeInsets.only(left: 4.0),
                                                child: Container(
                                                  width: 200,
                                                  child: Text(
                                                    '겨울 여행 크리스마스 여행 따뜻한 겨울 최고의 겨울'
                                                        .insertZwj(),
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                    ),
                                                    softWrap: true,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              ClipRRect(
                                                borderRadius:
                                                BorderRadius.circular(8.0),
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  color: Colors.grey,
                                                  height: 300,
                                                  width: 300,
                                                  child: Text('image'),
                                                ),
                                                /*Image.network(
                                                                      tripImages[index],
                                                                      width: 100,
                                                                      fit: BoxFit.cover,
                                                                    ),*/
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // 카드 클릭 시 동작
                  print('카드 클릭됨');
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                // backgroundImage: NetworkImage(profileImageUrl),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'tripTitle',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'userName',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          // 여행 사진들
                          Container(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 4,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ClipRRect(
                                    child: Container(
                                      alignment: Alignment.center,
                                      color: Colors.grey,
                                      height: 100,
                                      width: 100,
                                      child: Text('image'),
                                    ),
                                    /*Image.network(
                              tripImages[index],
                              width: 100,
                              fit: BoxFit.cover,
                            ),*/
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'description',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // 카드 클릭 시 동작
                  print('카드 클릭됨');
                },
                child: Padding(
                  padding:
                  EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                // backgroundImage: NetworkImage(profileImageUrl),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'tripTitle',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'userName',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          // 여행 사진들
                          Container(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 4,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ClipRRect(
                                    child: Container(
                                      alignment: Alignment.center,
                                      color: Colors.grey,
                                      height: 100,
                                      width: 100,
                                      child: Text('image'),
                                    ),
                                    /*Image.network(
                              tripImages[index],
                              width: 100,
                              fit: BoxFit.cover,
                            ),*/
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'description',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ) ,
      ),
    );
  }
}
