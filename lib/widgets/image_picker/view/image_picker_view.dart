import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/view/image_picker.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/viewModel(Provider)/image_picker_provider.dart';

class ImagePicker extends StatefulWidget {
  final int maxSelectableCount;
  final Color selectedColor;
  final int pickerGridCount;
  final double removeButtonSize;
  final String requestType;
  final bool showCameraIcon;

  const ImagePicker({
    super.key,
    this.maxSelectableCount = 10,
    this.selectedColor = Colors.blue,
    this.pickerGridCount = 3,
    this.removeButtonSize = 20.0,
    this.requestType = "common",
    this.showCameraIcon = true,
  });

  @override
  State<ImagePicker> createState() => _ImagePickerState();
}

class _ImagePickerState extends State<ImagePicker> with WidgetsBindingObserver {
  late ImagePickerViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _viewModel = context.read<ImagePickerViewModel>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _viewModel.handleAppResumed();
    }
    if (state == AppLifecycleState.paused) {
      _viewModel.handleAppPaused();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ImagePickerViewModel,
        ({List<AssetEntity> selectedAssets, bool appLifeResumed})>(
      selector: (context, viewModel) => (
        selectedAssets: viewModel.state.selectedAssets,
        appLifeResumed: viewModel.state.appLifeResumed
      ),
      builder: (context, state, child) {
        if (state.appLifeResumed) {
          return const Scaffold();
        } else {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text(
                "Image Picker View Example",
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            body: _buildListView(state.selectedAssets),
          );
        }
      },
    );
  }

  Widget _buildListView(List<AssetEntity> selectedAssets) {
    return Container(
      color: Colors.grey,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(right: 5.0),
            child: GestureDetector(
              onTap: () async {
                _viewModel.runThrottled(
                  'onImagePickerButtonPressed',
                  () async {
                    _viewModel.clearSelectedAssets();
                    await _viewModel.loadAlbumListAndAssets();
                    _viewModel.setGridCount(widget.pickerGridCount);
                    _viewModel.setSelectedColor(widget.selectedColor);
                    _viewModel.setMaxSelectableCount(widget.maxSelectableCount);
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
                width: 150.0,
                height: 150.0,
                color: Colors.black87,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                    Text(
                        '${selectedAssets.length}/${widget.maxSelectableCount}',
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 150.0,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: selectedAssets.length,
                itemBuilder: (context, index) {
                  AssetEntity assetEntity = selectedAssets[index];
                  return _buildAssetItem(assetEntity);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetItem(AssetEntity assetEntity) {
    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: SizedBox(
        width: 150.0,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
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
                VideoDurationWidget(assetEntity: assetEntity),
              _buildRemoveButton(assetEntity),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRemoveButton(AssetEntity assetEntity) {
    return Positioned(
      top: 5,
      right: 5,
      child: GestureDetector(
        onTap: () {
          _viewModel.toggleImageSelection(assetEntity);
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
