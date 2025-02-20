import 'package:flutter/material.dart';
import 'package:flutter_state_mvvm/models/image_picker_model.dart';
import 'package:flutter_state_mvvm/views/image_picker_view.dart';
import 'package:flutter_state_mvvm/widgets/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

//상태 클래스
class ImagePickerState {
  final List<AssetPathEntity> albumList;
  final List<AssetEntity> assetList;
  final List<AssetEntity> selectedImages;
  final AssetPathEntity? selectedAlbum;
  final int maxSelectableCount;
  final int initialIndex;
  final bool isLoading;
  final String? errorMessage;

  ImagePickerState({
    this.albumList = const [],
    this.assetList = const [],
    this.selectedImages = const [],
    this.selectedAlbum,
    this.maxSelectableCount = 10,
    this.initialIndex = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  ImagePickerState copyWith({
    List<AssetPathEntity>? albumList,
    List<AssetEntity>? assetList,
    List<AssetEntity>? selectedImages,
    AssetPathEntity? selectedAlbum,
    int? maxSelectableCount,
    int? initialIndex,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ImagePickerState(
      albumList: albumList ?? this.albumList,
      assetList: assetList ?? this.assetList,
      selectedImages: selectedImages ?? this.selectedImages,
      selectedAlbum: selectedAlbum ?? this.selectedAlbum,
      maxSelectableCount: maxSelectableCount ?? this.maxSelectableCount,
      initialIndex: initialIndex ?? this.initialIndex,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ImagePickerViewModel extends ChangeNotifier {
  final List<AssetEntity> _selectedImages = [];
  final ImagePickerModel _model; //model 인스턴스
  ImagePickerState _state; //state 인스턴스, View 상태 관리

  ImagePickerViewModel(this._model)
      : _state = ImagePickerState(
          albumList: [],
          selectedImages: [],
          selectedAlbum: null,
          maxSelectableCount: 10,
          initialIndex: 0,
        ){
    init();
  }

  ImagePickerState get state => _state; //외부에서 읽을 수 있도록 Getter 제공

  Future<void> init() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _model.init();
      _updateState(_state.copyWith(albumList: _model.albumList, selectedAlbum: _model.selectedAlbum, assetList: _model.assetList));
    } catch (e) {
      _updateState(_state.copyWith(errorMessage: e.toString()));
    } finally {
      _updateState(_state.copyWith(isLoading: false));
    }
  }

  // 2. 앨범 선택하기
  Future<void> selectAlbum(AssetPathEntity selectedAlbum) async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _model.selectAlbum(selectedAlbum);
      _updateState(_state.copyWith(selectedAlbum: _model.selectedAlbum, assetList: _model.assetList));
    } catch (e) {
      _updateState(_state.copyWith(errorMessage: e.toString()));
    } finally {
      _updateState(_state.copyWith(isLoading: false));
    }
  }

  // 4. 사진 선택하기 // 5. 선택된 사진 제거하기
  void SelectedImage(AssetEntity image) {
    if (!_model.selectedImages.contains(image)) {
      if(_model.selectedImages.length < _state.maxSelectableCount)  {
          _model.addSelectedImage(image);
        }
    } else {
        _model.removeSelectedImage(image);
    }
    _updateState(_state.copyWith(selectedImages: _model.selectedImages));
  }


  // 6. 선택된 사진의 최대 개수 설정하기
  void setMaxSelectableCount(int count) {
    _model.setMaxSelectableCount(count);
    _updateState(_state.copyWith(maxSelectableCount: count));
  }

  // 7. 전체 화면에서 사진 보기 (초기 인덱스 설정)
  void setInitialIndexForFullScreen(int index) {
    _model.setInitialIndexForFullScreen(index);
    _updateState(_state.copyWith(initialIndex: index));
  }

  // 8. 사진 선택 완료하기 (선택된 사진 목록 반환)
  List<AssetEntity> getSelectedPhotos() {
    return _model.getSelectedPhotos();
  }

  // 9. 상태 초기화
  void initPickerState(int maxCount) {
    _model.clearSelectedImages();
    setMaxSelectableCount(maxCount);
  }

  Future<void> pickAssets({
    required int maxCount,
    required RequestType requestType,
    required BuildContext context,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return CustomImagePicker();
        },
      ),
    );
    if (result.isNotEmpty || result != null) {
      _updateState(_state.copyWith(selectedImages: result));
    }
  }

  void _updateState(ImagePickerState newState) {
    _state = newState;
    notifyListeners();
  }
}
