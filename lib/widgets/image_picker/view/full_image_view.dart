import 'package:flutter/material.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/viewModel(Provider)/image_picker_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:provider/provider.dart';

class FullScreenImage extends StatefulWidget {
  const FullScreenImage({super.key});

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.black,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        Selector<ImagePickerViewModel, int>(
          selector: (context, viewModel) =>
              viewModel.state.selectedImages.length,
          builder: (context, selectedCount, child) {
            return Padding(
              padding: const EdgeInsets.only(right: 22.0),
              child: Row(
                children: [
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
                  _buildSendButton(context),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // App Bar 전송 버튼
  GestureDetector _buildSendButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: const Text(
        '전송',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.0),
      ),
    );
  }

  // Body 위젯
  Widget _buildBody() {
    return Selector<ImagePickerViewModel, List<AssetEntity>>(
      selector: (context, viewModel) => viewModel.state.assetList,
      builder: (context, assetList, child) {
        return PageView.builder(
          controller: context.read<ImagePickerViewModel>().pageController,
          itemCount: assetList.length,
          itemBuilder: (context, index) {
            final assetEntity = assetList[index];
            return _buildImageItem(
                assetEntity, context.read<ImagePickerViewModel>());
          },
        );
      },
    );
  }

  // 이미지 아이템 위젯 분리
  Widget _buildImageItem(
      AssetEntity assetEntity, ImagePickerViewModel viewModel) {
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
        // 이미지 선택 버튼
        _buildImageSelectButton(assetEntity, viewModel),
      ],
    );
  }

  // 이미지 선택 버튼 위젯
  Widget _buildImageSelectButton(
      AssetEntity assetEntity, ImagePickerViewModel viewModel) {
    return Selector<ImagePickerViewModel, bool>(
      selector: (context, viewModel) =>
          viewModel.state.selectedImages.contains(assetEntity),
      builder: (context, isSelected, child) {
        final selectedImages = viewModel.state.selectedImages;
        final selectedIndex = selectedImages.indexOf(assetEntity);
        return Positioned.fill(
          child: Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {
                viewModel.selectedImage(assetEntity);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 5.0, 22.0, 0.0),
                child: Selector<ImagePickerViewModel, Color>(
                  selector: (context, viewModel) =>
                      viewModel.state.selectedColor,
                  builder: (context, selectedColor, child) {
                    return Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: BoxDecoration(
                        color: isSelected ? selectedColor : Colors.white70,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isSelected ? Colors.transparent : Colors.black54,
                          width: 3.5,
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            isSelected ? "${selectedIndex + 1}" : "",
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                            ),
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
      },
    );
  }
}
