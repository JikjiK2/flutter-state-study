import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PostListView extends StatefulWidget {
  const PostListView({super.key});

  @override
  State<PostListView> createState() => _PostListViewState();
}

class _PostListViewState extends State<PostListView> {
  final bool _isLoading = false;
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
        title: const Text(
          '채널 목록',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // 뒤로가기 아이콘
          onPressed: () {
            Navigator.pop(context); // 이전 화면으로 돌아가기
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: Colors.black,
            onPressed: () {
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            color: Colors.black,
            onPressed: () {
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
                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
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
                            const Row(
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
                            const SizedBox(height: 10),
                            // 여행 사진들
                            SizedBox(
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
                                        child: const Text('image'),
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
                            const SizedBox(height: 10),
                            const Text(
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
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
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
                            const Row(
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
                            const SizedBox(height: 10),
                            // 여행 사진들
                            SizedBox(
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
                                        child: const Text('image'),
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
                            const SizedBox(height: 10),
                            const Text(
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
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
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
                          const Row(
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
                          const SizedBox(height: 10),
                          // 여행 사진들
                          SizedBox(
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
                                      child: const Text('image'),
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
                          const SizedBox(height: 10),
                          const Text(
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
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
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
                          const Row(
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
                          const SizedBox(height: 10),
                          // 여행 사진들
                          SizedBox(
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
                                      child: const Text('image'),
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
                          const SizedBox(height: 10),
                          const Text(
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
