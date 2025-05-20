import 'package:flutter/material.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/viewModel(Provider)/image_picker_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:provider/provider.dart';

class ImagePicker extends StatefulWidget {
  final bool isClear;
  final int viewGridCount;
  final int maxSelectableCount;
  final Color selectedColor;
  final bool isGrid;
  final int pickerGridCount;
  final double removeButtonSize;
  final String requestType;
  final EdgeInsets padding;
  final double imageSize;
  final double imageSpacing;
  final bool showCameraIcon;

  const ImagePicker({
    super.key,
    this.isClear = true,
    this.viewGridCount = 3,
    this.maxSelectableCount = 10,
    this.selectedColor = Colors.blue,
    this.isGrid = false,
    this.pickerGridCount = 3,
    this.removeButtonSize = 20.0,
    this.requestType = "common",
    this.padding = const EdgeInsets.all(2.0),
    this.imageSize = 150.0,
    this.imageSpacing = 5.0,
    this.showCameraIcon = true,
  });

  @override
  State<ImagePicker> createState() => _ImagePickerState();
}

class _ImagePickerState extends State<ImagePicker> {
  @override
  Widget build(BuildContext context) {
    return Selector<ImagePickerViewModel, List<AssetEntity>>(
      selector: (context, viewModel) => viewModel.state.selectedImages,
      builder: (context, selectedImages, child) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<ImagePickerViewModel>().clearSelectedImages();
                  },
                  child: const Text('선택 완료')),
            ],
          ),
          body: widget.isGrid
              ? _buildGridView(selectedImages)
              : _buildListView(selectedImages),
        );
      },
    );
  }

  // GridView 위젯 분리
  Widget _buildGridView(List<AssetEntity> selectedImages) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: selectedImages.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.viewGridCount),
      itemBuilder: (context, index) {
        AssetEntity assetEntity = selectedImages[index];
        return _buildAssetItem(assetEntity);
      },
    );
  }

  // ListView 위젯 분리
  Widget _buildListView(List<AssetEntity> selectedImages) {
    return Container(
      color: Colors.grey,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(right: 10.0),
            child: GestureDetector(
              onTap: () async {
                context.read<ImagePickerViewModel>().runThrottled(
                  'onImagePickerButtonPressed',
                  () async {
                    final viewModel = context.read<ImagePickerViewModel>();
                    await viewModel.loadAlbumList(widget.requestType);
                    viewModel.setGridCount(widget.pickerGridCount);
                    viewModel.setSelectedColor(widget.selectedColor);
                    viewModel.setMaxSelectableCount(widget.maxSelectableCount);
                    if (widget.isClear) {
                      await viewModel.init();
                      viewModel.clearSelectedImages();
                    }
                    await viewModel.init();
                    if (!mounted) return;
                    Navigator.pushNamed(
                      context,
                      '/imagePicker',
                    );
                  },
                  const Duration(milliseconds: 500),
                );
              },
              child: Container(
                width: widget.imageSize,
                height: widget.imageSize,
                color: Colors.black87,
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: widget.imageSize,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: selectedImages.length,
                itemBuilder: (context, index) {
                  AssetEntity assetEntity = selectedImages[index];
                  return _buildAssetItem(assetEntity);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 이미지 아이템 위젯 분리
  Widget _buildAssetItem(AssetEntity assetEntity) {
    return Padding(
      padding: EdgeInsets.only(right: widget.imageSpacing),
      child: SizedBox(
        width: widget.imageSize,
        child: Padding(
          padding: widget.padding,
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
                _buildVideoDuration(assetEntity),
              _buildRemoveButton(assetEntity),
            ],
          ),
        ),
      ),
    );
  }

  // 동영상 길이 표시 위젯 분리
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
    );
  }

  // 이미지 제거 버튼 위젯 분리
  Widget _buildRemoveButton(AssetEntity assetEntity) {
    return Positioned(
      top: 5,
      right: 5,
      child: GestureDetector(
        onTap: () {
          context.read<ImagePickerViewModel>().removeImage(assetEntity);
        },
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close,
            color: Colors.white,
            size: widget.removeButtonSize,
          ),
        ),
      ),
    );
  }
}
