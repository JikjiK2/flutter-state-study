import 'package:flutter/material.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/viewModel(Provider)/image_picker_provider.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/view/full_image_view.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:provider/provider.dart';

class CustomImagePicker extends StatefulWidget {
  const CustomImagePicker({super.key});

  @override
  State<CustomImagePicker> createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ImagePickerViewModel>(builder: (context, viewModel, child) {
            final state = viewModel.state;
            if (state.errorMessage != null) {
    return Center(
      child: Text('Error: ${state.errorMessage}'),
    );
            }
            return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      // 앨범 선택을 위한 버튼
      title: DropdownButton<AssetPathEntity>(
        value: state.selectedAlbum,
        onChanged: (AssetPathEntity? value) {
          // 선택한 앨범 저장, 선택한 앨범의 이미지 목록 저장
          viewModel.selectAlbum(value!);
        },
        items: state.albumList.map<DropdownMenuItem<AssetPathEntity>>(
            (AssetPathEntity album) {
              // 각각의 앨범 이름 및 앨범 이미지 개수
          return DropdownMenuItem<AssetPathEntity>(
            value: album,
            child: FutureBuilder<int>(
              future: album.assetCountAsync,
              builder: (context, snapshot) {
                String subtitle = "${snapshot.data}";
                return Text("${album.name} ($subtitle)");
              },
            ),
          );
        }).toList(),
      ),
      actions: [
        // 이미지 선택 완료
        GestureDetector(
            onTap: () {
              Navigator.pop(context, viewModel.getSelectedPhotos());
            },
            child: const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: Icon(Icons.check),
              ),
            ))
      ],
    ),
    body: state.isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : GridView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: state.assetList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemBuilder: (context, index) {
              AssetEntity assetEntity = state.assetList[index];
              return assetWidget(assetEntity, index);
            },
          ),
            );
          });
  }

  // GridView 표시될 각각의 요소 (이미지 1개)
  Widget assetWidget(AssetEntity assetEntity, int index) =>
      Consumer<ImagePickerViewModel>(
          builder: (context, viewModel, child) {
        final state = viewModel.state;
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state.errorMessage != null) {
          return Center(
            child: Text('Error: ${state.errorMessage}'),
          );
        }
        return Stack(
          children: [
            // 이미지 표시
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  viewModel.selectedImage(assetEntity);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                      viewModel.selectedImages.contains(assetEntity)
                              ? Colors.blue
                              : Colors.transparent,
                      width:
                      viewModel.selectedImages.contains(assetEntity)
                              ? 3.0
                              : 3.0,
                    ),
                  ),
                  child: AssetEntityImage(
                    assetEntity,
                    isOriginal: false,
                    thumbnailSize: const ThumbnailSize.square(250),
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
              ),
            ),
            // 동영상 우측 하단 동영상 길이 표시
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
                        // 동영상 길이
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
            // 이미지 선택 버튼
            Positioned.fill(
              child: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    viewModel.selectedImage(assetEntity);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: Container(
                      width: 28.0,
                      height: 28.0,
                      decoration: BoxDecoration(
                        color: viewModel.selectedImages.contains(assetEntity)
                            ? Colors.blue
                            : Colors.white70,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: viewModel.selectedImages.contains(assetEntity)
                              ? Colors.transparent
                              : Colors.black54,
                          width: 2.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "${viewModel.selectedImages.indexOf(assetEntity) + 1}",
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                            color: viewModel.selectedImages.contains(assetEntity)
                                ? Colors.white
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 이미지 전체 화면 버튼
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: GestureDetector(
                  onTap: () {
                    viewModel.setInitialIndexForFullScreen(assetEntity);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const FullScreenImage();
                        },
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(3.0)),
                      child: const Icon(
                        size: 18.0,
                        Icons.open_in_full,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      });
}
