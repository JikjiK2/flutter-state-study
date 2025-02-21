import 'package:flutter/material.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/viewModel(Provider)/image_picker_provider.dart';
import 'package:flutter_state_mvvm/widgets/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:provider/provider.dart';

class ImagePickerView extends StatefulWidget {
  const ImagePickerView({super.key});

  @override
  State<ImagePickerView> createState() => _ImagePickerViewState();
}

class _ImagePickerViewState extends State<ImagePickerView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ImagePickerViewModel>(
        builder: (context, viewModel, child) {
      return Scaffold(
        body: GridView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: viewModel.selectedImages.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3),
          itemBuilder: (context, index) {
            AssetEntity assetEntity = viewModel.selectedImages[index];
            return Padding(
              padding: const EdgeInsets.all(2.0),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AssetEntityImage(
                      assetEntity,
                      isOriginal: false,
                      thumbnailSize: const ThumbnailSize.square(1000),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                        );
                      },
                    ),
                  ),
                  if (assetEntity.type == AssetType.video)
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: FutureBuilder<int?>(
                              future: assetEntity.durationWithOptions(),
                              // 동영상 길이 가져 오기
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final duration = snapshot.data!;
                                  int seconds = duration % 60;
                                  int minutes = (duration % 3600) ~/ 60;
                                  int hours = duration ~/ 3600;
                                  String formattedHours =
                                      hours.toString().padLeft(2, '0');
                                  String formattedMinutes =
                                      minutes.toString().padLeft(2, '0');
                                  String formattedSeconds =
                                      seconds.toString().padLeft(2, '0');
                                  if (hours == 0) {
                                    return Text(
                                      '$formattedMinutes:$formattedSeconds',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w400),
                                    );
                                  } else {
                                    return Text(
                                      '$formattedHours:$formattedMinutes:$formattedSeconds',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w400),
                                    );
                                  }
                                } else {
                                  return const SizedBox();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const CustomImagePicker();
                },
              ),
            );
          },
          child: const Icon(Icons.image),
        ),
      );
    });
  }
}
