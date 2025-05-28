import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/viewModel(Provider)/image_picker_provider.dart';

class _SelectionCircle extends StatelessWidget {
  final bool isSelected;
  final int index;
  final Color selectedColor;

  const _SelectionCircle({
    required this.isSelected,
    required this.index,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.0,
      height: 48.0,
      decoration: BoxDecoration(
        color: isSelected ? selectedColor : Colors.white70,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.transparent : Colors.black54,
          width: 3.5,
        ),
      ),
      child: isSelected
          ? Center(
        child: Text(
          index.toString(),
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      )
          : null,
    );
  }
}

class ImageSelectButtonOptimized extends StatelessWidget {
  final AssetEntity assetEntity;

  const ImageSelectButtonOptimized({
    super.key,
    required this.assetEntity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 5.0, 22.0, 0.0),
          child: Selector<ImagePickerViewModel, _SelectionStateOptimized>(
            selector: (context, viewModel) {
              final indexMap = viewModel.state.selectedAssetIndexMap;
              final index = indexMap[assetEntity.id];

              return _SelectionStateOptimized(
                isSelected: index != null,
                displayIndex: index != null ? index + 1 : 0,
                selectedColor: viewModel.state.selectedColor,
              );
            },
            builder: (context, selectionState, child) {
              return GestureDetector(
                onTap: () => context.read<ImagePickerViewModel>()
                    .toggleImageSelection(assetEntity),
                child: _SelectionCircle(
                  isSelected: selectionState.isSelected,
                  index: selectionState.displayIndex,
                  selectedColor: selectionState.selectedColor,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SelectionStateOptimized {
  final bool isSelected;
  final int displayIndex;
  final Color selectedColor;

  const _SelectionStateOptimized({
    required this.isSelected,
    required this.displayIndex,
    required this.selectedColor,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is _SelectionStateOptimized &&
              isSelected == other.isSelected &&
              displayIndex == other.displayIndex &&
              selectedColor == other.selectedColor;

  @override
  int get hashCode =>
      isSelected.hashCode ^ displayIndex.hashCode ^ selectedColor.hashCode;
}