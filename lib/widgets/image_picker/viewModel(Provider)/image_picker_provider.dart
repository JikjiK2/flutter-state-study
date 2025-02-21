import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/model/image_picker_model.dart';
import 'package:photo_manager/photo_manager.dart';

//상태 클래스
class ImagePickerState {
  final List<AssetPathEntity> albumList;
  final List<AssetEntity> assetList;
  final AssetPathEntity? selectedAlbum;
  final int maxSelectableCount;
  final int initialIndex;
  final bool isLoading;
  final String? errorMessage;

  ImagePickerState({
    this.albumList = const [],
    this.assetList = const [],
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
      selectedAlbum: selectedAlbum ?? this.selectedAlbum,
      maxSelectableCount: maxSelectableCount ?? this.maxSelectableCount,
      initialIndex: initialIndex ?? this.initialIndex,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ImagePickerViewModel extends ChangeNotifier {
  final ImagePickerModel _model; //model 인스턴스
  ImagePickerState _state; //state 인스턴스, View 상태 관리
  late PageController _pageController;

  ImagePickerViewModel(this._model)
      : _state = ImagePickerState(
          albumList: [],
          selectedAlbum: null,
          maxSelectableCount: 10,
          initialIndex: 0,
        ) {
    init();
    _pageController = PageController(initialPage: _state.initialIndex);
  }

  ImagePickerState get state => _state; //외부에서 읽을 수 있도록 Getter 제공
  PageController get pageController => _pageController;
  List<AssetEntity> get selectedImages => _model.selectedImages;

  Future<void> init() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _model.init();
      _updateState(_state.copyWith(
          albumList: _model.albumList,
          selectedAlbum: _model.selectedAlbum,
          assetList: _model.assetList));
    } catch (e) {
      _updateState(_state.copyWith(errorMessage: e.toString()));
    } finally {
      _updateState(_state.copyWith(isLoading: false));
    }
  }

  // 2. 앨범 선택
  Future<void> selectAlbum(AssetPathEntity selectedAlbum) async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _model.selectAlbum(selectedAlbum);
      _updateState(_state.copyWith(
          selectedAlbum: _model.selectedAlbum, assetList: _model.assetList));
    } catch (e) {
      _updateState(_state.copyWith(errorMessage: e.toString()));
    } finally {
      _updateState(_state.copyWith(isLoading: false));
    }
  }

  // 4. 사진 선택 // 5. 선택된 사진 제거
  void selectedImage(AssetEntity image) async {
    if (!_model.selectedImages.contains(image)) {
      if (_model.selectedImages.length < _state.maxSelectableCount) {
        _model.addSelectedImage(image);
      }
    } else {
      _model.removeSelectedImage(image);
    }
    _updateState(_state.copyWith(selectedImages: _model.selectedImages));
  }

  // 6. 선택된 사진의 최대 개수 설정
  void setMaxSelectableCount(int count) {
    _model.setMaxSelectableCount(count);
    _updateState(_state.copyWith(maxSelectableCount: count));
  }

  // 7. 전체 화면 사진 보기 (초기 인덱스 설정)
  void setInitialIndexForFullScreen(AssetEntity assetEntity) {
    _model.setInitialIndexForFullScreen(assetEntity);
    _updateState(_state.copyWith(initialIndex: _model.initialIndex));
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_state.initialIndex);
      }
    });

  }

  // 8. 사진 선택 완료 (선택된 사진 목록 반환)
  List<AssetEntity> getSelectedPhotos() {
    return _model.getSelectedPhotos();
  }

  // 9. 상태 초기화
  void initPickerState(int maxCount) {
    _model.clearSelectedImages();
    setMaxSelectableCount(maxCount);
  }

  void _updateState(ImagePickerState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
