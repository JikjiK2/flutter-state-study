import 'package:flutter/material.dart';
import 'package:flutter_state_mvvm/models/image_picker_model.dart';
import 'package:flutter_state_mvvm/providers/image_picker_provider.dart';
import 'package:flutter_state_mvvm/views/full_image_view.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:provider/provider.dart';

class CustomImagePicker extends StatefulWidget {
  @override
  State<CustomImagePicker> createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  void updateSelectedAssetList(List<AssetEntity> updatedList) {
    setState(() {
      // selectedAssetList = updatedList;
    });
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final model = ImagePickerModel();
        final viewModel = ImagePickerViewModel(model);
        return viewModel;
      },
      child:
          Consumer<ImagePickerViewModel>(builder: (context, viewModel, child) {
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
            title: DropdownButton<AssetPathEntity>(
              value: state.selectedAlbum,
              onChanged: (AssetPathEntity? value) {
                //여기서 하는 일이 선택한 앨범 저장, 선택한 앨범의 이미지 목록 저장
                viewModel.selectAlbum(value!);
              },
              items: state.albumList.map<DropdownMenuItem<AssetPathEntity>>(
                  (AssetPathEntity album) {
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
      }),
    );
  }

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
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  viewModel.SelectedImage(assetEntity);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          state.selectedImages.contains(assetEntity)
                              ? Colors.blue
                              : Colors.transparent,
                      width:
                          state.selectedImages.contains(assetEntity)
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
            if (assetEntity.type == AssetType.video)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: FutureBuilder<int?>(
                        future: assetEntity.durationWithOptions(),
                        // 동영상 길이 가져오기
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
                            if (hours == 0)
                              return Text(
                                '${formattedMinutes}:${formattedSeconds}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w400),
                              );
                            else
                              return Text(
                                '${formattedHours}:${formattedMinutes}:${formattedSeconds}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w400),
                              );
                          } else {
                            return const SizedBox();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    viewModel.SelectedImage(assetEntity);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: Container(
                      width: 28.0,
                      height: 28.0,
                      decoration: BoxDecoration(
                        color: state.selectedImages.contains(assetEntity)
                            ? Colors.blue
                            : Colors.white70,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: state.selectedImages.contains(assetEntity)
                              ? Colors.transparent
                              : Colors.black54,
                          width: 2.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "${state.selectedImages.indexOf(assetEntity) + 1}",
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                            color: state.selectedImages.contains(assetEntity)
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
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImage(
                          selectedIndex: index,
                          assetList: state.assetList,
                          maxCount: state.maxSelectableCount,
                          selectedAssetList: state.selectedImages,
                          assetEntity: assetEntity,
                          updateSelectedAssetList: updateSelectedAssetList,
                        ),
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
