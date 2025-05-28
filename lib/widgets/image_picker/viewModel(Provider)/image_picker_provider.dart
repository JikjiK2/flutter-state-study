import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_state_mvvm/widgets/image_picker/model/image_picker_model.dart';

//상태 클래스
class ImagePickerState {
  final List<AssetPathEntity> albumList;
  final List<AssetEntity> assetList;
  final AssetPathEntity? selectedAlbum;

  final int maxSelectableCount;
  final Color selectedColor;
  final int pickerGridCount;
  final RequestType requestType;

  final bool isLoading;
  final String? errorMessage;

  final List<AssetEntity> selectedAssets;

  final int initialIndex;

  final bool cameraLoading;

  final File? selectedFile;
  final AssetEntity? capturedAsset;
  final List<AssetEntity> pageViewDisplayItems;

  final bool appLifeResumed;

  final bool isPoppedByCode;

  final Map<String, int> selectedAssetIndexMap;

  ImagePickerState({
    this.albumList = const [],
    this.assetList = const [],
    this.selectedAlbum,
    this.maxSelectableCount = 10,
    this.initialIndex = 0,
    this.isLoading = false,
    this.errorMessage,
    this.selectedFile,
    this.cameraLoading = false,
    this.pageViewDisplayItems = const [],
    this.capturedAsset,
    this.requestType = RequestType.common,
    this.selectedAssets = const [],
    this.selectedColor = Colors.blue,
    this.pickerGridCount = 3,
    this.appLifeResumed = false,
    this.isPoppedByCode = false,
    required this.selectedAssetIndexMap,
  });

  ImagePickerState copyWith({
    List<AssetPathEntity>? albumList,
    List<AssetEntity>? assetList,
    List<AssetEntity>? selectedAssets,
    AssetPathEntity? selectedAlbum,
    int? maxSelectableCount,
    int? initialIndex,
    bool? isLoading,
    String? errorMessage,
    bool removeErrorMessage = false,
    int? pickerGridCount,
    Color? selectedColor,
    RequestType? requestType,
    File? selectedFile,
    bool clearSelectedFile = false,
    bool? cameraLoading,
    List<AssetEntity>? pageViewDisplayItems,
    AssetEntity? capturedAsset,
    bool clearCapturedAsset = false,
    bool? appLifeResumed,
    bool? isPoppedByCode,
  }) {
    final newSelectedAssets = selectedAssets ?? this.selectedAssets;
    final newIndexMap = <String, int>{};
    for (int i = 0; i < newSelectedAssets.length; i++) {
      newIndexMap[newSelectedAssets[i].id] = i;
    }

    return ImagePickerState(
      albumList: albumList ?? this.albumList,
      assetList: assetList ?? this.assetList,
      selectedAlbum: selectedAlbum ?? this.selectedAlbum,
      maxSelectableCount: maxSelectableCount ?? this.maxSelectableCount,
      initialIndex: initialIndex ?? this.initialIndex,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          removeErrorMessage ? null : errorMessage ?? this.errorMessage,
      selectedColor: selectedColor ?? this.selectedColor,
      pickerGridCount: pickerGridCount ?? this.pickerGridCount,
      requestType: requestType ?? this.requestType,
      selectedFile:
          clearSelectedFile ? null : selectedFile ?? this.selectedFile,
      cameraLoading: cameraLoading ?? this.cameraLoading,
      pageViewDisplayItems: pageViewDisplayItems ?? this.pageViewDisplayItems,
      capturedAsset:
          clearCapturedAsset ? null : capturedAsset ?? this.capturedAsset,
      appLifeResumed: appLifeResumed ?? this.appLifeResumed,
      isPoppedByCode: isPoppedByCode ?? this.isPoppedByCode,
      selectedAssets: selectedAssets ?? newSelectedAssets,
      selectedAssetIndexMap: newIndexMap,
    );
  }
}

class ImagePickerViewModel extends ChangeNotifier {
  final ImagePickerModel _model;
  ImagePickerState _state;

  late PageController _pageController;

  ImagePickerState get state => _state;

  PageController get pageController => _pageController;

  ImagePickerViewModel(this._model)
      : _state = ImagePickerState(selectedAssetIndexMap: {}) {
    _initialize();
  }

  void Function(AssetEntity capturedAsset, String imagePath)? onImageCaptured;

  void setOnImageCapturedCallback(
      void Function(AssetEntity capturedAsset, String imagePath) callback) {
    onImageCaptured = callback;
  }

  Future<void> openCamera() async {
    clearCapturedAsset();
    try {
      await _model.openNativeCamera();
    } on PlatformException catch (e) {
      _updateState(_state.copyWith(
          cameraLoading: false, errorMessage: "카메라 실행 오류: ${e.message}"));
    } catch (e) {
      _updateState(_state.copyWith(
          cameraLoading: false, errorMessage: "오류 발생: ${e.toString()}"));
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    final String? imagePath = call.arguments as String?;
    switch (call.method) {
      case 'imageCaptured':
        await _handleImageCaptured(imagePath);
        break;
      case 'cameraCanceled':
        _handleCameraCanceled();
        break;
      case 'cameraError':
        _handleCameraError(imagePath);
        break;
      case 'videoCaptured':
        _handleVideoCaptured(imagePath);
        break;
    }
  }

  Future<void> openVideoCamera() async {
    clearCapturedAsset();
    try {
      await _model.openNativeVideoCamera();
    } on PlatformException catch (e) {
      _updateState(_state.copyWith(
          cameraLoading: false, errorMessage: "카메라 실행 오류: ${e.message}"));
    } catch (e) {
      _updateState(_state.copyWith(
          cameraLoading: false, errorMessage: "오류 발생: ${e.toString()}"));
    }
  }

  Future<void> _handleVideoCaptured(String? videoPath) async {
    if (videoPath == null) {
      _handleCameraError('videoPath is null');
      return;
    }
    try {
      final AssetEntity? capturedAsset =
          await _model.handleCapturedVideo(videoPath);
      if (capturedAsset != null) {
        _addImageToSelection(capturedAsset, videoPath);
      }
    } catch (e) {
      _handleCameraError(e.toString());
    }
  }

  Future<void> _handleImageCaptured(String? imagePath) async {
    if (imagePath == null) {
      _handleCameraError('imagePath is null');
      return;
    }
    try {
      final AssetEntity? capturedAsset =
          await _model.handleCapturedImage(imagePath);
      if (capturedAsset != null) {
        _addImageToSelection(capturedAsset, imagePath);
      }
    } catch (e) {
      _handleCameraError(e.toString());
    }
  }

  void _addImageToSelection(AssetEntity capturedAsset, String imagePath) {
    final newSelectedImages = List<AssetEntity>.from(_state.selectedAssets);

    if (newSelectedImages.length < _state.maxSelectableCount) {
      newSelectedImages.add(capturedAsset);
      _updateState(_state.copyWith(
        capturedAsset: capturedAsset,
        cameraLoading: false,
        selectedAssets: newSelectedImages,
        pageViewDisplayItems: newSelectedImages,
        initialIndex: newSelectedImages.length - 1,
      ));

      onImageCaptured?.call(capturedAsset, imagePath);
      navigateToCapturedImage(newSelectedImages.length - 1);
    } else {
      _handleMaximumSelectionExceeded();
    }
  }

  void _handleMaximumSelectionExceeded() {
    _updateState(_state.copyWith(
        cameraLoading: false,
        errorMessage: 'image_picker_max_selection_exceeded'));
  }

  void navigateToCapturedImage(int index) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(index);
      }
    });
  }

  void updateInitialIndex(int index) {
    _updateState(_state.copyWith(initialIndex: index));
  }

  void _handleCameraCanceled() {
    _updateState(_state.copyWith(cameraLoading: false));
  }

  void _handleCameraError(String? errorMessage) {
    _updateState(
        _state.copyWith(cameraLoading: false, errorMessage: 'camera_error'));
  }

  Future<void> clearCapturedAsset() async {
    _updateState(_state.copyWith(
        cameraLoading: true,
        capturedAsset: null,
        pageViewDisplayItems: _state.selectedAssets));
  }

  Future<void> onCameraNavigationDone() async {
    if (!_state.cameraLoading) {
      List<AssetEntity> updateSelectedAssets = List.from(_state.selectedAssets);
      if (_state.capturedAsset != null) {
        if (updateSelectedAssets.contains(_state.capturedAsset)) {
          updateSelectedAssets.remove(_state.capturedAsset);
        }
      }
      _updateState(_state.copyWith(
          selectedAssets: updateSelectedAssets,
          cameraLoading: false,
          capturedAsset: null));

      openCamera();
      loadAlbumListAndAssets();
    }
  }

  Future<void> _initialize() async {
    _pageController = PageController(initialPage: _state.initialIndex);
    ImagePickerModel.platform.setMethodCallHandler(_handleMethodCall);
    await loadAlbumListAndAssets();
  }

  Future<void> loadAlbumListAndAssets() async {
    try {
      final List<AssetPathEntity> albums;
      albums = await _model.fetchAlbumList(_state.requestType);
      List<AssetEntity> assetList = [];
      AssetPathEntity? currentAlbum;

      if (albums.isNotEmpty) {
        currentAlbum = albums.first;
        assetList = await _model.fetchAssetsForAlbum(currentAlbum);
      }

      _updateState(_state.copyWith(
        isLoading: false,
        albumList: albums,
        selectedAlbum: currentAlbum,
        assetList: assetList,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: "앨범 가져오기 및 앨범 요소 가져오기 오류 - ${e.toString()}"));
    }
  }

  Future<void> changeAlbum(AssetPathEntity selectedAlbum) async {
    _updateState(_state.copyWith(
        isLoading: true, selectedAlbum: selectedAlbum, errorMessage: null));
    try {
      final List<AssetEntity> assets;
      assets = await _model.fetchAssetsForAlbum(selectedAlbum);
      _updateState(_state.copyWith(isLoading: false, assetList: assets));
    } catch (e) {
      _updateState(_state.copyWith(
          isLoading: false, errorMessage: "앨범 변경 오류 - ${e.toString()}"));
    }
  }

  void toggleImageSelection(AssetEntity image) async {
    final List<AssetEntity> currentSelectedAssets;
    currentSelectedAssets = List<AssetEntity>.from(_state.selectedAssets);
    final isSelected =
        currentSelectedAssets.any((element) => element.id == image.id);
    if (isSelected) {
      currentSelectedAssets.removeWhere((element) => element.id == image.id);
    } else {
      if (currentSelectedAssets.length < _state.maxSelectableCount) {
        currentSelectedAssets.add(image);
      }
    }
    _updateState(_state.copyWith(selectedAssets: currentSelectedAssets));
  }

  void setMaxSelectableCount(int count) {
    if (count > 0) {
      _updateState(_state.copyWith(maxSelectableCount: count));
      if (_state.selectedAssets.length > count) {
        final newSelected = _state.selectedAssets.sublist(0, count);
        _updateState(_state.copyWith(selectedAssets: newSelected));
      }
    }
  }

  void prepareFullScreenView(
      AssetEntity assetEntity, List<AssetEntity>? sourceList) {
    final displayList = sourceList ?? _state.assetList;
    int nInitialIndex = displayList.indexWhere((e) => e.id == assetEntity.id);
    if (nInitialIndex == -1) nInitialIndex = 0;

    _updateState(_state.copyWith(initialIndex: nInitialIndex));
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_state.initialIndex);
      }
    });
  }

  Future<void> setCameraLoading() async {
    _updateState(_state.copyWith(cameraLoading: false));
  }

  void handleAppResumed() {
    _updateState(_state.copyWith(appLifeResumed: false));
  }

  void handleAppPaused() {
    _updateState(_state.copyWith(appLifeResumed: true));
  }

  void setGridCount(int count) {
    if (count > 0) {
      _updateState(_state.copyWith(pickerGridCount: count));
    }
  }

  void setSelectedColor(Color color) {
    _updateState(_state.copyWith(selectedColor: color));
  }

  void clearSelectedAssets() {
    _updateState(_state.copyWith(selectedAssets: []));
  }

  void setRequestType(RequestType requestType) {
    _updateState(_state.copyWith(requestType: requestType));
  }

  void _updateState(ImagePickerState newState) {
    _state = newState;
    notifyListeners();
  }

  void setPoppedByCode(bool value) {
    if (_state.isPoppedByCode != value) {
      _updateState(_state.copyWith(isPoppedByCode: value));
    }
  }

  String? validateSelection() {
    if (state.selectedAssets.isEmpty) {
      return '이미지를 선택해주세요.';
    }
    return null;
  }

  /*Future<bool> completeSelection(BuildContext context) async {
    final validationError = validateSelection();
    if (validationError != null) {
      return false;
    }
    setPoppedByCode(true);
    return true;
  }*/

  @override
  void dispose() {
    ImagePickerModel.platform.setMethodCallHandler(null);
    _pageController.dispose();
    super.dispose();
  }

  final Map<Object, int> _lastThrottledActionTimes = {};

  // 지정된 액션에 쓰로틀을 적용하여 실행하는 함수
  // actionIdentifier: 쓰로틀을 적용할 액션을 구분하는 고유한 키 (예: 'send_button_tap')
  // action: 실제로 실행할 비동기 액션 (Future<void>를 반환하는 함수)
  // throttleDuration: 쓰로틀 시간 간격 (이 시간 내에는 액션이 최대 한 번만 실행됨)
  Future<void> runThrottled(Object actionIdentifier,
      Future<void> Function() action, Duration throttleDuration) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastExecutionTime = _lastThrottledActionTimes[actionIdentifier] ?? 0;

    // 지정된 쓰로틀 시간 간격이 지났는지 확인
    if (now - lastExecutionTime >= throttleDuration.inMilliseconds) {
      // 시간 간격이 지났으면 액션 실행
      _lastThrottledActionTimes[actionIdentifier] = now; // 마지막 실행 시간 업데이트

      try {
        await action(); // 실제 액션(비동기 함수) 실행을 기다림
      } catch (e) {
        // 액션 실행 중 발생한 오류 처리 (필요에 따라 로깅, 오류 상태 업데이트 등)
        print("Throttled action $actionIdentifier failed: $e");
        // 오류 발생 시에도 쓰로틀 상태는 유지될 수 있습니다.
      }
    } else {
      // 시간 간격 내에 있으면 액션 실행하지 않고 무시
      print("Action $actionIdentifier throttled.");
    }
  }
}
