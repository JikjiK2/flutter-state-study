import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/components/image_selection_button.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/viewModel(Provider)/image_picker_provider.dart';
import 'dart:io';

class FullScreenImage extends StatefulWidget {
  const FullScreenImage({super.key});

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage>
    with WidgetsBindingObserver {
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
      // This was causing issues, simplified for now.
      // _viewModel.navigateToCapturedImage(_viewModel.state.initialIndex);
    }
    if (state == AppLifecycleState.paused) {
      _viewModel.handleAppPaused();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImagePickerViewModel>(builder: (context, viewModel, child) {
      return viewModel.state.appLifeResumed
          ? const Scaffold()
          : Scaffold(
        backgroundColor: Colors.black,
        appBar: _buildAppBar(),
        body: _buildBody(),
      );
    });
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.black,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        Selector<ImagePickerViewModel, int>(
          selector: (context, viewModel) =>
          viewModel.state.selectedAssets.length,
          builder: (context, selectedCount, child) {
            return Padding(
              padding: const EdgeInsets.only(right: 22.0),
              child: Row(
                children: [
                  if (selectedCount > 0) ...{
                    Text(
                      '$selectedCount',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    _buildSendButton(context, false)
                  } else ...{
                    _buildSendButton(context, true)
                  }
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  GestureDetector _buildSendButton(BuildContext context, bool empty) {
    return GestureDetector(
      onTap: empty
          ? null
          : () {
        context.read<ImagePickerViewModel>().setPoppedByCode(true);
        Navigator.popUntil(
            context, ModalRoute.withName('/imagePickerView'));
      },
      child: Text(
        '전송',
        style: TextStyle(
          color: empty ? Colors.grey : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15.0,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Selector<ImagePickerViewModel, List<AssetEntity>>(
      selector: (context, viewModel) => viewModel.state.assetList,
      builder: (context, assetList, child) {
        return PageView.builder(
          controller: context.read<ImagePickerViewModel>().pageController,
          itemCount: assetList.length,
          itemBuilder: (context, index) {
            final assetEntity = assetList[index];
            return FullScreenAssetItem(
              key: ValueKey(assetEntity.id),
              assetEntity: assetEntity,
            );
          },
          onPageChanged: (int index) {
            _viewModel.updateInitialIndex(index);
          },
        );
      },
    );
  }
}

class FullScreenAssetItem extends StatefulWidget {
  const FullScreenAssetItem({
    super.key,
    required this.assetEntity,
  });
  final AssetEntity assetEntity;

  @override
  State<FullScreenAssetItem> createState() => _FullScreenAssetItemState();
}

class _FullScreenAssetItemState extends State<FullScreenAssetItem> {
  VideoPlayerController? _videoController;
  bool _isVideo = false;

  @override
  void initState() {
    super.initState();
    _isVideo = widget.assetEntity.type == AssetType.video;
    if (_isVideo) {
      _initializeVideoController();
    }
  }

  void _initializeVideoController() async {
    final file = await widget.assetEntity.file;
    if (file == null || !mounted) return;

    _videoController = VideoPlayerController.file(file);

    _videoController!.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    await _videoController!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.85,
              maxWidth: screenWidth,
            ),
            child: Align(
              alignment: const Alignment(0, -0.2),
              child: _buildAssetView(),
            ),
          ),
        ),

        ImageSelectButtonOptimized(assetEntity: widget.assetEntity),

        if (_isVideo && _videoController?.value.isInitialized == true)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: _buildCustomVideoControls(),
          ),
      ],
    );
  }

  Widget _buildAssetView() {
    if (_isVideo) {
      if (_videoController?.value.isInitialized == true) {
        return AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        );
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    } else {
      return AssetEntityImage(
        widget.assetEntity,
        fit: BoxFit.contain,
        isOriginal: true,
      );
    }
  }

  Widget _buildCustomVideoControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VideoProgressIndicator(
          _videoController!,
          allowScrubbing: true,
          colors: const VideoProgressColors(
            playedColor: Colors.blue,
            bufferedColor: Colors.grey,
            backgroundColor: Colors.white24,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                _videoController!.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                setState(() {
                  _videoController!.value.isPlaying
                      ? _videoController!.pause()
                      : _videoController!.play();
                });
              },
            ),
            Text(
              '${_formatDuration(_videoController!.value.position)} / ${_formatDuration(_videoController!.value.duration)}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
