import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/components/image_selection_button.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/viewModel(Provider)/image_picker_provider.dart';

class CameraImageView extends StatefulWidget {
  const CameraImageView({super.key});

  @override
  State<CameraImageView> createState() => _CameraImageViewState();
}

class _CameraImageViewState extends State<CameraImageView>
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
      _viewModel.navigateToCapturedImage(_viewModel.state.initialIndex);
    }
    if (state == AppLifecycleState.paused) {
      _viewModel.handleAppPaused();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImagePickerViewModel>(builder: (context, viewModel, child) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) {
            return;
          } else {
            viewModel.onCameraNavigationDone();
            Navigator.pop(context);
          }
        },
        child: viewModel.state.appLifeResumed
            ? const Scaffold()
            : Scaffold(
                backgroundColor: Colors.black,
                appBar: _buildAppBar(),
                body: _buildBody(),
              ),
      );
    });
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: _buildBackButton(),
      elevation: 0,
      backgroundColor: Colors.black,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        _buildAppBarActions(),
      ],
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      onPressed: () {
        _viewModel.onCameraNavigationDone();
        Navigator.pop(context);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  Widget _buildAppBarActions() {
    return Selector<ImagePickerViewModel, int>(
      selector: (context, viewModel) => viewModel.state.selectedAssets.length,
      builder: (context, selectedCount, child) {
        return Padding(
          padding: const EdgeInsets.only(right: 22.0),
          child: Row(
            children: [
              if (selectedCount > 0) ...[
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
              ] else ...[
                _buildSendButton(context, true)
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return Selector<ImagePickerViewModel, List<AssetEntity>>(
      selector: (context, viewModel) => viewModel.state.pageViewDisplayItems,
      builder: (context, pageViewDisplayItems, child) {
        bool hasJumpedToLastPage = false;
        if (!hasJumpedToLastPage) {
          _viewModel.navigateToCapturedImage(pageViewDisplayItems.length - 1);
          hasJumpedToLastPage = true;
        }

        return PageView.builder(
          controller: _viewModel.pageController,
          itemCount: pageViewDisplayItems.length,
          itemBuilder: (context, index) {
            final assetEntity = pageViewDisplayItems[index];
            return _buildImageItem(assetEntity);
          },
          onPageChanged: (int index) {
            _viewModel.updateInitialIndex(index);
          },
        );
      },
    );
  }

  Widget _buildImageItem(
      AssetEntity assetEntity) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        Center(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.85,
              maxWidth: screenWidth,
            ),
            child: Align(
              alignment: const Alignment(0, -0.2),
              child: AssetEntityImage(
                assetEntity,
                fit: BoxFit.contain,
                isOriginal: true,
              ),
            ),
          ),
        ),
        ImageSelectButtonOptimized(assetEntity: assetEntity),
      ],
    );
  }

  GestureDetector _buildSendButton(BuildContext context, bool empty) {
    return GestureDetector(
      onTap: empty
          ? null
          : () {
              _viewModel.setPoppedByCode(true);
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
}
