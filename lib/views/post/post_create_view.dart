import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class PostCreateView extends StatefulWidget {
  const PostCreateView({super.key});

  @override
  State<PostCreateView> createState() => _PostCreateViewState();
}

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class _PostCreateViewState extends State<PostCreateView> {
  final _formKey = GlobalKey<FormState>();
  String _textFormFieldValue = '';
  final List<XFile?> _pickedImages = [];
  XFile? file;

  Future<void> _pickImage() async {
    ImagePicker().pickImage(source: ImageSource.gallery).then((image) {
      if (image != null) {
        setState(() {
          file = XFile(image.path);
        });
      }
    });
  }

  Future<void> _multiPickImage() async {
    final List<XFile>? images = await ImagePicker().pickMultiImage();
    if (images != null) {
      setState(() {
        for(var image in images) {
          String fileName = path.basename(image.path);
          if(!_pickedImages.any((img) => path.basename(img!.path) == fileName))
            _pickedImages.add(image);
        }
      });
    }
  }

  final TextEditingController TitleController = TextEditingController();
  final TextEditingController ContentController = TextEditingController();

  Future<void> addPost() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    Reference _storage = FirebaseStorage.instance
        .ref("test")
        .child("pick_images")
        .child("image1");
    await _storage.child(file as String);
    final url = await _storage.getDownloadURL();
    DocumentReference postDocRef = await _firestore.collection('post').add({
      'user_id': 'abcd1234',
      'title': TitleController.text,
      'created_at': Timestamp.fromDate(DateTime.now()),
      //firestore = Timestamp, flutter =
      'post_image': url,
      'like': 0,
      'report': 0,
      'visible': true
    });
    await postDocRef.collection('content').add({
      'content': ContentController.text,
    });

    TitleController.clear();
    ContentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final String title = TitleController.text;
    final String content = ContentController.text;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: Text(
          '게시글 작성',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // 뒤로가기 아이콘
          onPressed: () {
            Navigator.pop(context); // 이전 화면으로 돌아가기
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.file_upload_outlined),
            color: Colors.black,
            onPressed: () {
              // 프로필 아이콘 클릭 시 동작
              _multiPickImage();
              print('공유 아이콘 클릭됨');
            },
          ),
          IconButton(
            icon: Icon(Icons.map_outlined),
            color: Colors.black,
            onPressed: () {
              // 프로필 아이콘 클릭 시 동작
              _pickImage();
              print('지도 아이콘 클릭됨');
            },
          ),
          IconButton(
            icon: Icon(Icons.check),
            color: Colors.black,
            onPressed: () {
              print('체크 아이콘 클릭됨');
              for(int i = 0; i < _pickedImages.length; i++)
                print(_pickedImages[i]!.path);
            },
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: ScrollConfiguration(
          behavior: NoGlowScrollBehavior(),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('제목'),
                      Form(
                        key: _formKey,
                        child: Column(children: [
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return '1자 이상 입력해주세요.';
                              }
                            },
                            onSaved: (value) {
                              setState(() {
                                _textFormFieldValue = value!;
                              });
                            },
                            controller: TitleController,
                            decoration: const InputDecoration(
                                labelText: '제목',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 2,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                  strokeAlign: BorderSide.strokeAlignOutside,
                                )),
                                errorStyle: TextStyle(),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ))),
                            maxLines: 1,
                            maxLength: 30,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            // keyboardType: TextInputType.none,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return '1자 이상 입력해주세요.';
                              }
                            },
                            decoration: const InputDecoration(
                                labelText: '내용',
                                alignLabelWithHint: true,
                                //labelText 위쪽 정렬
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 2,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                  strokeAlign: BorderSide.strokeAlignOutside,
                                )),
                                errorStyle: TextStyle(),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ))),
                            minLines: 5,
                            maxLines: null,
                            maxLength: 500,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            textInputAction: TextInputAction.next,
                            controller: ContentController,
                          ),
                        ]),
                      ),
                      Container(
                        color: Colors.grey,
                        width: 100,
                        height: 100,
                        child: (file != null)
                            ? Image.file(
                                File(file!.path),
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image,
                                size: 30, color: Colors.white),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (int i = 0; i < _pickedImages.length; i++)
                              Container(
                                color: Colors.grey,
                                width: 100,
                                height: 100,
                                child: (_pickedImages[i] != null)
                                    ? Image.file(
                                        File(_pickedImages[i]!.path),
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.image,
                                        size: 30, color: Colors.white),
                              ),
                            const SizedBox(
                              width: 10.0,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              final formKeyState = _formKey.currentState!;
                              if (formKeyState.validate()) {
                                formKeyState.save();
                              }
                              addPost();
                            },
                            child: const Text('확인'),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}
