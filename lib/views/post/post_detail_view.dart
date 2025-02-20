import 'package:flutter/material.dart';

class PostDetailView extends StatefulWidget {
  const PostDetailView({super.key});

  @override
  State<PostDetailView> createState() =>
      _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // 뒤로가기 아이콘
          onPressed: () {
            Navigator.pop(context); // 이전 화면으로 돌아가기
          },
        ),
        /* actions: [
          IconButton(
            icon: Icon(Icons.file_upload_outlined),
            color: Colors.black,
            onPressed: () {
              // 프로필 아이콘 클릭 시 동작
              print('공유 아이콘 클릭됨');
            },
          ),
          IconButton(
            icon: Icon(Icons.map_outlined),
            color: Colors.black,
            onPressed: () {
              // 프로필 아이콘 클릭 시 동작
              print('지도 아이콘 클릭됨');
            },
          ),
          IconButton(
            icon: Icon(Icons.check),
            color: Colors.black,
            onPressed: () {
              print('체크 아이콘 클릭됨');
            },
          ),
        ],*/
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: 100.0),
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        minRadius: 20.0,
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '작성자',
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 3.0,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '2025.2.12 18:17 (등록일 및 시간)',
                                style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '글 제목입니다.',
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Text(
                          '국민의 자유와 권리는 헌법에 열거되지 아니한 이유로 경시되지 아니한다. \n\n대한민국의 주권은 국민에게 있고, 모든 권력은 국민으로부터 나온다. \n\n공공필요에 의한 재산권의 수용·사용 또는 제한 및 그에 대한 보상은 법률로써 하되, 정당한 보상을 지급하여야 한다.'),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  decoration: BoxDecoration(color: Colors.grey),
                  width: double.infinity,
                  height: 400,
                  alignment: Alignment.center,
                  child: Text('사진'),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  width: double.infinity,
                  color: Colors.amberAccent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          minRadius: 10.0,
                                        ),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        Text(
                                          '익명1',
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                              Text('안녕하세요. 댓글1', style: TextStyle(fontSize: 12.0),),
                              Row(
                                children: [
                                  Text(
                                    '2025.2.12 18:17 (등록일 및 시간)',
                                    style: TextStyle(
                                        fontSize: 8.0,
                                        color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0,),
                      Row(
                        children: [
                          const SizedBox(width: 20.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          minRadius: 10.0,
                                        ),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        Text(
                                          '익명2',
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                              Text('안녕하세요. 대댓글1', style: TextStyle(fontSize: 12.0),),
                              Row(
                                children: [
                                  Text(
                                    '2025.2.12 18:17 (등록일 및 시간)',
                                    style: TextStyle(
                                        fontSize: 8.0,
                                        color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0,),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          minRadius: 10.0,
                                        ),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        Text(
                                          '익명3',
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                              Text('안녕하세요. 댓글2', style: TextStyle(fontSize: 12.0),),
                              Row(
                                children: [
                                  Text(
                                    '2025.2.12 18:17 (등록일 및 시간)',
                                    style: TextStyle(
                                        fontSize: 8.0,
                                        color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0,),
                      Row(
                        children: [
                          const SizedBox(width: 20.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          minRadius: 10.0,
                                        ),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        Text(
                                          '익명4',
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                              Text('안녕하세요. 대댓글2', style: TextStyle(fontSize: 12.0),),
                              Row(
                                children: [
                                  Text(
                                    '2025.2.12 18:17 (등록일 및 시간)',
                                    style: TextStyle(
                                        fontSize: 8.0,
                                        color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
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
