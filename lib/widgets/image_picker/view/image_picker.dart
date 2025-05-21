import 'package:flutter/material.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/viewModel(Provider)/image_picker_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:provider/provider.dart';

class CustomImagePicker extends StatefulWidget {
  const CustomImagePicker({
    super.key,
  });

  @override
  State<CustomImagePicker> createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 옵저버 해제
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      context.read<ImagePickerViewModel>().handleAppResumed();
    }
    if (state == AppLifecycleState.paused) {
      context.read<ImagePickerViewModel>().handleAppPaused();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<dynamic>(
      onPopInvokedWithResult: (bool? didPop, dynamic result) {
        final viewModel = context.read<ImagePickerViewModel>();
        if (viewModel.state.isPoppedByCode) {
          viewModel.setPoppedByCode(false);
        } else {
          if (didPop!) {
            viewModel.clearSelectedImages();
          }
        }
      },
      child: Selector<ImagePickerViewModel,
          ({bool cameraLoading, AssetEntity? capturedAsset})>(
        selector: (context, viewModel) => (
          cameraLoading: viewModel.state.cameraLoading,
          capturedAsset: viewModel.state.capturedAsset,
        ),
        builder: (context, state, child) {
          if (state.cameraLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.pushNamed(context, '/cameraImage').then((_) {
                  context.read<ImagePickerViewModel>().onCameraNavigationDone();
                });
              }
            });
          }
          return Selector<ImagePickerViewModel,
                  ({String? errorMessage, bool appLifeResumed})>(
              selector: (context, viewModel) => (
                    errorMessage: viewModel.state.errorMessage,
                    appLifeResumed: viewModel.state.appLifeResumed
                  ),
              builder: (context, state, child) {
                if (state.errorMessage != null) {
                  return Center(
                    child: Text('오류: $state.errorMessage'),
                  );
                }
                if (state.appLifeResumed) {
                  return const Scaffold();
                } else {
                  return Scaffold(
                    appBar: _buildAppBar(context),
                    body: _buildBody(context),
                  );
                }
              });
        },
      ),
    );
  }

  // AppBar 위젯
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      title: _buildAlbumDropdown(context),
      actions: [
        _buildCompleteButton(context),
      ],
    );
  }

  // 앨범 리스트 드롭 다운 버튼 위젯
  Widget _buildAlbumDropdown(BuildContext context) {
    return Selector<ImagePickerViewModel, List<AssetPathEntity>>(
      selector: (context, viewModel) => viewModel.state.albumList,
      builder: (context, albumList, child) {
        return Selector<ImagePickerViewModel, AssetPathEntity?>(
          selector: (context, viewModel) => viewModel.state.selectedAlbum,
          builder: (context, selectedAlbum, child) {
            return DropdownButton<AssetPathEntity>(
              value: selectedAlbum,
              onChanged: (AssetPathEntity? value) {
                context.read<ImagePickerViewModel>().selectAlbum(value!);
              },
              items: albumList.asMap().entries.map((entry) {
                int index = entry.key;
                AssetPathEntity album = entry.value;
                bool isFirstItem = (index == 0);
                String albumDisplayName = isFirstItem ? "전체보기" : album.name;

                return DropdownMenuItem<AssetPathEntity>(
                  value: album,
                  child: FutureBuilder<int>(
                    future: album.assetCountAsync,
                    builder: (context, snapshot) {
                      String subtitle =
                          snapshot.data != null ? "${snapshot.data}" : "";
                      return Text("$albumDisplayName $subtitle");
                    },
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  // 이미지 선택 완료 버튼 위젯
  Widget _buildCompleteButton(BuildContext context) {
    return Selector<ImagePickerViewModel, List<AssetEntity>>(
        selector: (context, viewModel) => (viewModel.state.selectedImages),
        builder: (context, selectedImages, child) {
          return GestureDetector(
            onTap: () {
              if(selectedImages.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('이미지를 선택해주세요.'),
                  ),
                );
              }
              else{
                context.read<ImagePickerViewModel>().init();
                context.read<ImagePickerViewModel>().setPoppedByCode(true);
                Navigator.pop(context,
                    context.read<ImagePickerViewModel>().getSelectedPhotos());
              }
            },
            child: const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: Icon(Icons.check),
              ),
            ),
          );
        });
  }

  // Body 위젯
  Widget _buildBody(BuildContext context) {
    return Selector<ImagePickerViewModel,
        ({bool isLoading, List<AssetEntity> assetList})>(
      selector: (context, viewModel) => (
        isLoading: viewModel.state.isLoading,
        assetList: viewModel.state.assetList
      ),
      builder: (context, state, child) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: state.assetList.length + 1,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 3.0,
            crossAxisSpacing: 3.0,
            crossAxisCount:
                context.read<ImagePickerViewModel>().state.pickerGridCount,
          ),
          itemBuilder: (context, index) {
            if (index == 0) {
              return cameraWidget(context);
            } else {
              AssetEntity assetEntity = state.assetList[index - 1];
              return assetWidget(assetEntity, index - 1);
            }
          },
        );
      },
    );
  }

  // GirdView 첫번째 카메라 위젯
  Widget cameraWidget(BuildContext context) {
    final viewModel = context.read<ImagePickerViewModel>();
    return Selector<ImagePickerViewModel,
        ({int maxSelectableCount, int selectedImagesLength})>(
      selector: (context, viewModel) => (
        maxSelectableCount: viewModel.state.maxSelectableCount,
        selectedImagesLength: viewModel.state.selectedImages.length
      ),
      builder: (context, state, child) {
        return GestureDetector(
          onTap: () {
            if (state.selectedImagesLength < state.maxSelectableCount) {
              viewModel.openCamera();
            }
            if (state.selectedImagesLength == state.maxSelectableCount) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('최대 ${state.maxSelectableCount}개까지 선택 가능합니다.'),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Selector<ImagePickerViewModel,
                ({bool isLoading, String? errorMessage, bool appLifeResumed})>(
              selector: (context, viewModel) => (
                isLoading: viewModel.state.isLoading,
                errorMessage: viewModel.state.errorMessage,
                appLifeResumed: viewModel.state.appLifeResumed
              ),
              builder: (context, state, child) {
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
                return Container(
                  color: Colors.black87,
                  child: state.appLifeResumed
                      ? const SizedBox()
                      : const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // GridView 표시될 각각의 요소 (이미지 1개)
  Widget assetWidget(AssetEntity assetEntity, int index) {
    return Selector<ImagePickerViewModel,
        ({bool isLoading, String? errorMessage})>(
      selector: (context, viewModel) => (
        isLoading: viewModel.state.isLoading,
        errorMessage: viewModel.state.errorMessage
      ),
      builder: (context, state, child) {
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
        return _buildAssetItem(
            assetEntity, context.read<ImagePickerViewModel>());
      },
    );
  }

  // 이미지 아이템 위젯
  Widget _buildAssetItem(
      AssetEntity assetEntity, ImagePickerViewModel viewModel) {
    return Stack(
      children: [
        // 이미지 표시
        _buildImageDisplay(assetEntity, viewModel),
        // 동영상 우측 하단 동영상 길이 표시
        if (assetEntity.type == AssetType.video)
          _buildVideoDuration(assetEntity),
        // 이미지 선택 버튼
        _buildImageSelectButton(assetEntity, viewModel),
        // 이미지 전체 화면 버튼
        _buildFullScreenButton(assetEntity, viewModel),
      ],
    );
  }

  // 이미지 표시 위젯
  Widget _buildImageDisplay(
      AssetEntity assetEntity, ImagePickerViewModel viewModel) {
    return Selector<
        ImagePickerViewModel,
        ({
          bool isSelected,
          Color selectedColor,
          int maxSelectableCount,
          int selectedImagesLength
        })>(
      selector: (context, viewModel) => (
        isSelected: viewModel.state.selectedImages.contains(assetEntity),
        selectedColor: viewModel.state.selectedColor,
        maxSelectableCount: viewModel.state.maxSelectableCount,
        selectedImagesLength: viewModel.state.selectedImages.length
      ),
      builder: (context, state, child) {
        return Positioned.fill(
          child: GestureDetector(
            onTap: () {
              viewModel.selectedImage(assetEntity);
              if (state.isSelected == false && (state.selectedImagesLength >= state.maxSelectableCount)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('최대 ${state.maxSelectableCount}개까지 선택 가능합니다.'),
                  ),
                );
              }
            },
            child:
                //이미지 위에 border를 씌우는 느낌
                Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
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
                if (state.isSelected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: state.selectedColor,
                          width: 3.0,
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  //이미지 자체의 border 수정, 선택 시 이미지 확대 및 축소
  Widget _buildImageDisplay2(
      AssetEntity assetEntity, ImagePickerViewModel viewModel) {
    return Selector<
        ImagePickerViewModel,
        ({
          bool isSelected,
          Color selectedColor,
          int maxSelectableCount,
          int selectedImagesLength
        })>(
      selector: (context, viewModel) => (
        isSelected: viewModel.state.selectedImages.contains(assetEntity),
        selectedColor: viewModel.state.selectedColor,
        maxSelectableCount: viewModel.state.maxSelectableCount,
        selectedImagesLength: viewModel.state.selectedImages.length
      ),
      builder: (context, state, child) {
        return Positioned.fill(
          child: GestureDetector(
            onTap: () {
              viewModel.selectedImage(assetEntity);
              if (state.selectedImagesLength >= state.maxSelectableCount) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('최대 ${state.maxSelectableCount}개까지 선택 가능합니다.'),
                  ),
                );
              }
            },
            child:
                //이미지 위에 border를 씌우는 느낌
                Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: state.isSelected
                      ? state.selectedColor
                      : Colors.transparent,
                  width: state.isSelected ? 3.0 : 0.0,
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
        );
      },
    );
  }

  // 동영상 길이 위젯
  Widget _buildVideoDuration(AssetEntity assetEntity) {
    return Positioned.fill(
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
                  String formattedHours = hours.toString().padLeft(2, '0');
                  String formattedMinutes = minutes.toString().padLeft(2, '0');
                  String formattedSeconds = seconds.toString().padLeft(2, '0');
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
                          color: Colors.white, fontWeight: FontWeight.w400),
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
    );
  }

  // 이미지 선택 버튼 위젯
  Widget _buildImageSelectButton(
      AssetEntity assetEntity, ImagePickerViewModel viewModel) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: () {
            viewModel.selectedImage(assetEntity);
          },
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Selector<ImagePickerViewModel,
                ({bool isSelected, Color selectedColor})>(
              selector: (context, viewModel) => (
                isSelected:
                    viewModel.state.selectedImages.contains(assetEntity),
                selectedColor: viewModel.state.selectedColor
              ),
              builder: (context, state, child) {
                return Container(
                  width: 28.0,
                  height: 28.0,
                  decoration: BoxDecoration(
                    color:
                        state.isSelected ? state.selectedColor : Colors.white70,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: state.isSelected
                          ? Colors.transparent
                          : Colors.black54,
                      width: 2.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      state.isSelected
                          ? "${viewModel.state.selectedImages.indexOf(assetEntity) + 1}"
                          : "",
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                        color: state.isSelected
                            ? Colors.white
                            : Colors.transparent,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // 전체 화면 버튼 위젯
  Widget _buildFullScreenButton(
      AssetEntity assetEntity, ImagePickerViewModel viewModel) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: GestureDetector(
          onTap: () {
            viewModel.setInitialIndexForFullScreen(assetEntity);
            Navigator.pushNamed(context, '/fullImage');
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
    );
  }
}
