import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/viewModel(Provider)/image_picker_provider.dart';

class CustomImagePicker extends StatefulWidget {
  const CustomImagePicker({
    super.key,
  });

  @override
  State<CustomImagePicker> createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker>
    with WidgetsBindingObserver {
  late ImagePickerViewModel _viewModel;

  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _viewModel = context.read<ImagePickerViewModel>();
    _viewModel.setOnImageCapturedCallback((capturedAsset, imagePath) {
      Navigator.of(context).pushNamed(
        '/cameraImage',
        arguments: {
          'capturedAsset': capturedAsset,
          'imagePath': imagePath,
        },
      );
    });
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
    return Consumer<ImagePickerViewModel>(
      builder: (context, viewModel, child) {
        return PopScope<dynamic>(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, dynamic result) {
            if (didPop) {
              return;
            } else {
              viewModel.clearSelectedAssets();
              Navigator.pop(context);
            }
          },
          child: _buildScaffoldContent(viewModel),
        );
      },
    );
  }

  Widget _buildScaffoldContent(ImagePickerViewModel viewModel) {
    return Selector<ImagePickerViewModel,
        ({String? errorMessage, bool appLifeResumed})>(
      selector: (context, viewModel) => (
        errorMessage: viewModel.state.errorMessage,
        appLifeResumed: viewModel.state.appLifeResumed
      ),
      builder: (context, state, child) {
        if (state.errorMessage != null) {
          return _buildErrorScaffold(state.errorMessage!);
        }
        if (state.appLifeResumed) {
          return const Scaffold();
        }

        return Scaffold(
          appBar: _buildAppBar(context),
          body: _buildBody(context),
        );
      },
    );
  }

  Widget _buildErrorScaffold(String errorMessage) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오류'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text('오류: $errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('뒤로 가기'),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leading: IconButton(
          onPressed: () {
            _viewModel.clearSelectedAssets();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back)),
      elevation: 0,
      title: _buildAlbumDropdown(context),
      actions: [
        _buildCompleteButton(context),
      ],
    );
  }

  Widget _buildAlbumDropdown(BuildContext context) {
    return Selector<ImagePickerViewModel,
        ({List<AssetPathEntity> albumList, AssetPathEntity? selectedAlbum})>(
      selector: (context, viewModel) => (
        albumList: viewModel.state.albumList,
        selectedAlbum: viewModel.state.selectedAlbum,
      ),
      builder: (context, state, child) {
        return DropdownButtonHideUnderline(
          child: DropdownButton<AssetPathEntity>(
            dropdownColor: Theme.of(context).colorScheme.secondary,
            value: state.selectedAlbum,
            onChanged: (AssetPathEntity? value) {
              context.read<ImagePickerViewModel>().changeAlbum(value!);
            },
            items: state.albumList.asMap().entries.map((entry) {
              int index = entry.key;
              AssetPathEntity album = entry.value;
              bool isFirstItem = (index == 0);
              String albumDisplayName = isFirstItem ? "최근 항목" : album.name;

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
          ),
        );
      },
    );
  }

  Widget _buildCompleteButton(BuildContext context) {
    return Selector<ImagePickerViewModel, int>(
      selector: (context, viewModel) => viewModel.state.selectedAssets.length,
      builder: (context, selectedCount, child) {
        return GestureDetector(
          onTap: () => _handleCompleteButtonTap(context),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Icon(
                Icons.check,
                color: selectedCount > 0
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
                size: 30.0,
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleCompleteButtonTap(BuildContext context) {
    final viewModel = context.read<ImagePickerViewModel>();
    final selectedAssets = viewModel.state.selectedAssets;

    if (selectedAssets.isEmpty) {
      _showSnackBar('이미지를 선택해주세요.');
    } else {
      viewModel.setPoppedByCode(true);
      Navigator.pop(context, selectedAssets);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Selector<ImagePickerViewModel, bool>(
      selector: (context, viewModel) => viewModel.state.isLoading,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildImageGrid();
      },
    );
  }

  Widget _buildImageGrid() {
    return Selector<ImagePickerViewModel, int>(
      selector: (context, viewModel) => viewModel.state.assetList.length,
      builder: (context, assetCount, child) {
        return PageStorage(
          bucket: _bucket,
          child: GridView.builder(
            key: PageStorageKey<String>(
                'albumGridVew_${_viewModel.state.selectedAlbum?.name}'),
            physics: const BouncingScrollPhysics(),
            itemCount: assetCount + 1,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 3.0,
              crossAxisSpacing: 3.0,
              crossAxisCount:
                  context.read<ImagePickerViewModel>().state.pickerGridCount,
            ),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _CameraWidget();
              } else {
                final assetEntity = context
                    .read<ImagePickerViewModel>()
                    .state
                    .assetList[index - 1];
                return _AssetWidget(
                  assetEntity: assetEntity,
                  index: index - 1,
                );
              }
            },
          ),
        );
      },
    );
  }
}

class _CameraWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<ImagePickerViewModel, ({int maxCount, int selectedCount})>(
      selector: (context, viewModel) => (
        maxCount: viewModel.state.maxSelectableCount,
        selectedCount: viewModel.state.selectedAssets.length,
      ),
      builder: (context, state, child) {
        return GestureDetector(
          onTap: () async {
            _handleCameraTap(context, state.maxCount, state.selectedCount);
          },
          child: Container(
            color: const Color(0xFF202020),
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  void _handleCameraTap(BuildContext context, int maxCount, int selectedCount) {
    if (selectedCount < maxCount) {
      _showMyDialog(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('최대 $maxCount개까지 선택 가능합니다.')),
      );
    }
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
          backgroundColor: Theme.of(context).colorScheme.onSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Text(
            "촬영",
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(left: 24.0),
                    backgroundColor: Theme.of(context).colorScheme.onSecondary,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    alignment: Alignment.centerLeft,
                    minimumSize: const Size.fromHeight(50.0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(0),
                      ),
                    ),
                  ),
                  onPressed: () {
                    context.read<ImagePickerViewModel>().runThrottled(
                      'onNativeCameraButtonPressed',
                      () async {
                        Navigator.pop(context);
                        final viewModel = context.read<ImagePickerViewModel>();
                        viewModel.openCamera();
                      },
                      const Duration(milliseconds: 500),
                    );
                  },
                  child: const Text(
                    "사진 촬영",
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(left: 24.0),
                    backgroundColor: Theme.of(context).colorScheme.onSecondary,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    alignment: Alignment.centerLeft,
                    minimumSize: const Size.fromHeight(50.0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(0),
                      ),
                    ),
                  ),
                  onPressed: () {
                    context.read<ImagePickerViewModel>().runThrottled(
                      'onNativeCameraButtonPressed',
                      () async {
                        Navigator.pop(context);
                        final viewModel = context.read<ImagePickerViewModel>();
                        viewModel.openVideoCamera();
                      },
                      const Duration(milliseconds: 500),
                    );
                  },
                  child: const Text(
                    "동영상 촬영",
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AssetWidget extends StatelessWidget {
  final AssetEntity assetEntity;
  final int index;

  const _AssetWidget({
    required this.assetEntity,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AssetImageWidget(assetEntity: assetEntity),
        if (assetEntity.type == AssetType.video)
          VideoDurationWidget(assetEntity: assetEntity),
        SelectionButtonWidget(assetEntity: assetEntity),
        FullScreenButtonWidget(assetEntity: assetEntity),
      ],
    );
  }
}

class AssetImageWidget extends StatelessWidget {
  final AssetEntity assetEntity;

  const AssetImageWidget({super.key, required this.assetEntity});

  @override
  Widget build(BuildContext context) {
    return Selector<ImagePickerViewModel,
        ({bool isSelected, Color selectedColor})>(
      selector: (context, viewModel) => (
        isSelected: viewModel.state.selectedAssets.contains(assetEntity),
        selectedColor: viewModel.state.selectedColor,
      ),
      builder: (context, state, child) {
        return Positioned.fill(
          child: GestureDetector(
            onTap: () => _handleImageTap(context),
            child: Stack(
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
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleImageTap(BuildContext context) {
    final viewModel = context.read<ImagePickerViewModel>();
    final isSelected = viewModel.state.selectedAssets.contains(assetEntity);
    final selectedCount = viewModel.state.selectedAssets.length;
    final maxCount = viewModel.state.maxSelectableCount;

    viewModel.toggleImageSelection(assetEntity);

    if (!isSelected && selectedCount >= maxCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('최대 $maxCount개까지 선택 가능합니다.')),
      );
    }
  }
}

class VideoDurationWidget extends StatelessWidget {
  final AssetEntity assetEntity;

  const VideoDurationWidget({super.key, required this.assetEntity});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 5.0,
      right: 5.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(3.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        child: FutureBuilder<int?>(
          future: assetEntity.durationWithOptions(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();

            final duration = snapshot.data!;
            final formattedDuration = _formatDuration(duration);

            return Text(
              formattedDuration,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.0,
                fontWeight: FontWeight.w400,
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDuration(int duration) {
    int seconds = duration % 60;
    int minutes = (duration % 3600) ~/ 60;
    int hours = duration ~/ 3600;

    String formattedHours = hours.toString().padLeft(2, '0');
    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String formattedSeconds = seconds.toString().padLeft(2, '0');

    if (hours == 0) {
      return '$formattedMinutes:$formattedSeconds';
    } else {
      return '$formattedHours:$formattedMinutes:$formattedSeconds';
    }
  }
}

class SelectionButtonWidget extends StatelessWidget {
  final AssetEntity assetEntity;

  const SelectionButtonWidget({super.key, required this.assetEntity});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 7.0,
      right: 7.0,
      child: Selector<ImagePickerViewModel,
          ({bool isSelected, int selectedAssetIndexMap, Color selectedColor})>(
        selector: (context, viewModel) {
          final indexMap = viewModel.state.selectedAssetIndexMap;
          final index = indexMap[assetEntity.id];
          final isSelected = index != null;
          final displayIndex = index != null ? index + 1 : 0;
          return (
            isSelected: isSelected,
            selectedAssetIndexMap: displayIndex,
            selectedColor: viewModel.state.selectedColor,
          );
        },
        builder: (context, state, child) {
          return GestureDetector(
            onTap: () {
              context
                  .read<ImagePickerViewModel>()
                  .toggleImageSelection(assetEntity);
            },
            child: Container(
              width: 28.0,
              height: 28.0,
              decoration: BoxDecoration(
                color: state.isSelected ? state.selectedColor : Colors.white70,
                shape: BoxShape.circle,
                border: Border.all(
                  color: state.isSelected ? Colors.transparent : Colors.black54,
                  width: 2.5,
                ),
              ),
              child: Center(
                child: Text(
                  state.isSelected ? "${state.selectedAssetIndexMap}" : "",
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                    color: state.isSelected ? Colors.white : Colors.transparent,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FullScreenButtonWidget extends StatelessWidget {
  final AssetEntity assetEntity;

  const FullScreenButtonWidget({super.key, required this.assetEntity});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 5.0,
      left: 5.0,
      child: GestureDetector(
        onTap: () {
          final viewModel = context.read<ImagePickerViewModel>();
          viewModel.prepareFullScreenView(
              assetEntity, viewModel.state.assetList);
          Navigator.pushNamed(context, '/fullImage');
        },
        child: Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(3.0),
          ),
          child: const Icon(
            size: 18.0,
            Icons.open_in_full,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
