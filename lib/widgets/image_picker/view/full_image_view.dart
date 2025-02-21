import 'package:flutter/material.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/viewModel(Provider)/image_picker_provider.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:provider/provider.dart';

class FullScreenImage extends StatefulWidget {
  const FullScreenImage({super.key});

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ImagePickerViewModel>(
      builder: (context, viewModel, child) {
        final state = viewModel.state;
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 22.0),
                child: Row(
                  children: [
                    Text(
                      '${viewModel.selectedImages.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        '전송',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: PageView.builder(
            controller: viewModel.pageController,
            itemCount: state.assetList.length,
            itemBuilder: (context, index) {
              final assetEntity = state.assetList[index];
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
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          viewModel.selectedImage(assetEntity);
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 5.0, 22.0, 0.0),
                          child: Container(
                            width: 48.0,
                            height: 48.0,
                            decoration: BoxDecoration(
                              color:
                                  viewModel.selectedImages.contains(assetEntity)
                                      ? Colors.blue
                                      : Colors.white70,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: viewModel.selectedImages
                                        .contains(assetEntity)
                                    ? Colors.transparent
                                    : Colors.black54,
                                width: 3.5,
                              ),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  "${viewModel.selectedImages.indexOf(assetEntity) + 1}",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: viewModel.selectedImages
                                            .contains(assetEntity)
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
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
