import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_state_mvvm/views/create_trip_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'destination_list_view.dart';
import 'login_view.dart'; // 로그인 화면
import 'profile_view.dart'; // 프로필 화면
import 'settings_view.dart'; // 설정 화면

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

final List<String> imgList = [
  'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
  'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
  'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
  'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
];

Widget imageSlider(path, index) => Container(
      width: double.infinity,
      height: 240,
      color: Colors.grey,
      child: Image.asset(path, fit: BoxFit.cover),
    );

Widget indicator(dynamic images, dynamic activeIndex) => Container(
    margin: const EdgeInsets.only(bottom: 20.0),
    alignment: Alignment.bottomCenter,
    child: AnimatedSmoothIndicator(
      activeIndex: activeIndex,
      count: images.length,
      effect: JumpingDotEffect(
          dotHeight: 6,
          dotWidth: 6,
          activeDotColor: Colors.white,
          dotColor: Colors.white.withOpacity(0.6)),
    ));

final List<Widget> imageSliders = imgList
    .map((item) => Container(
          child: Container(
            margin: const EdgeInsets.all(5.0),
            child: ClipRRect(
                child: Stack(
              children: <Widget>[
                Image.network(item, fit: BoxFit.cover, width: 1000.0),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(200, 0, 0, 0),
                          Color.fromARGB(0, 0, 0, 0)
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    child: Text(
                      'No. ${imgList.indexOf(item)} image',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            )),
          ),
        ))
    .toList();

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    int current = 0;
    final CarouselSliderController controller = CarouselSliderController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 계획'),
        /*flexibleSpace: Center(
          child: Text(
            '여행 계획',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        elevation: 0,*/
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: Colors.white,
            onPressed: () {
              // 검색 아이콘 클릭 시 동작
              print('검색 아이콘 클릭됨');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            color: Colors.white,
            onPressed: () {
              // 프로필 아이콘 클릭 시 동작
              print('프로필 아이콘 클릭됨');
            },
          ),
        ],
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey,
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /*Stack(alignment: Alignment.bottomCenter, children: <Widget>[
              Expanded(
                child: CarouselSlider(
                  items: imageSliders,
                  carouselController: _controller,
                  options: CarouselOptions(
                      viewportFraction: 1,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      aspectRatio: 2.0,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      }),
                ),
              ),
              Align(alignment: Alignment.bottomCenter, child: indicator(imageSliders, _current),)
            ]),*/
            CustomBtn('Login View', context, const LoginView()),
            const SizedBox(height: 10),
            CustomBtn('Destination View', context, const DestinationListView()),
            const SizedBox(height: 10),
            CustomBtn('Profile View', context, const ProfileView()),
            const SizedBox(height: 10),
            CustomBtn('Settings View', context, const SettingsView()),
            const SizedBox(height: 10),
            CustomBtn('CreateTrip View', context, const CreateTripView()),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

Widget CustomBtn(String text, BuildContext context, Widget nextPage) {
  return ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => nextPage),
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

