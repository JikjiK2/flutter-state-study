import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
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
  final List<AssetEntity> selectedImages;
  final Color selectedColor;
  final int pickerGridCount;
  RequestType requestType = RequestType.common;
  File? selectedFile;
  final bool cameraLoading;
  final List<AssetEntity> pageViewDisplayItems;
  final AssetEntity? capturedAsset;
  final bool appLifeResumed;
  final bool isPoppedByCode;

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
    required this.requestType,
    required this.selectedImages,
    required this.selectedColor,
    required this.pickerGridCount,
    this.appLifeResumed = false,
    this.isPoppedByCode = false,
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
    int? pickerGridCount,
    Color? selectedColor,
    RequestType? requestType,
    File? selectedFile,
    bool? cameraLoading,
    List<AssetEntity>? pageViewDisplayItems,
    AssetEntity? capturedAsset,
    bool? appLifeResumed,
    bool? isPoppedByCode,
  }) {
    return ImagePickerState(
      albumList: albumList ?? this.albumList,
      assetList: assetList ?? this.assetList,
      selectedAlbum: selectedAlbum ?? this.selectedAlbum,
      maxSelectableCount: maxSelectableCount ?? this.maxSelectableCount,
      initialIndex: initialIndex ?? this.initialIndex,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedImages: selectedImages ?? this.selectedImages,
      selectedColor: selectedColor ?? this.selectedColor,
      pickerGridCount: pickerGridCount ?? this.pickerGridCount,
      requestType: requestType ?? this.requestType,
      selectedFile: selectedFile ?? this.selectedFile,
      cameraLoading: cameraLoading ?? this.cameraLoading,
      pageViewDisplayItems: pageViewDisplayItems ?? this.pageViewDisplayItems,
      capturedAsset: capturedAsset ?? this.capturedAsset,
      appLifeResumed: appLifeResumed ?? this.appLifeResumed,
      isPoppedByCode: isPoppedByCode ?? this.isPoppedByCode,
    );
  }
}

class ImagePickerViewModel extends ChangeNotifier {
  final ImagePickerModel _model; //model 인스턴스
  ImagePickerState _state; //state 인스턴스, View 상태 관리
  late PageController _pageController;
  late StreamController<bool> _btnController;

  static const platform = MethodChannel('com.example.camera/intent');

  ImagePickerState get state => _state; //외부에서 읽을 수 있도록 Getter 제공
  PageController get pageController => _pageController;

  StreamController<bool> get btnController => _btnController;

  ImagePickerViewModel(this._model)
      : _state = ImagePickerState(
          albumList: [],
          selectedAlbum: null,
          maxSelectableCount: 10,
          initialIndex: 0,
          pickerGridCount: 3,
          selectedImages: [],
          selectedColor: Colors.blue,
          requestType: RequestType.common,
        ) {
    init();
    _pageController = PageController(initialPage: _state.initialIndex);
    _btnController = StreamController<bool>();
    platform.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> openCamera() async {
    try {
      clearCapturedAsset();
      await _model.openCamera();
      _updateState(_state.copyWith(selectedFile: _model.selectedFile));
    } on PlatformException catch (e) {
      _updateState(_state.copyWith(errorMessage: e.message));
    } catch (e) {
      _updateState(_state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'imageCaptured':
        final String? imagePath = call.arguments as String?;
        clearCapturedAsset();
        if (imagePath != null) {
          AssetEntity? capturedAsset;
          try {
            capturedAsset =
                await PhotoManager.editor.saveImageWithPath(imagePath);
            _updateState(_state.copyWith(capturedAsset: capturedAsset));
          } catch (e) {
            _updateState(_state.copyWith(errorMessage: e.toString()));
            return;
          }

          if (capturedAsset != null) {
            _model.setSelectedFile(File(imagePath));
            selectedImage(capturedAsset);
            _updateState(_state.copyWith(
                cameraLoading: true,
                selectedImages: _state.selectedImages,
                pageViewDisplayItems: _state.selectedImages,
                capturedAsset: capturedAsset));

            setInitialIndexForCameraImage();
          } else {
            _updateState(_state.copyWith(
                cameraLoading: false, errorMessage: '이미지 객체 생성 실패'));
          }
        } else {
          _updateState(_state.copyWith(
              cameraLoading: false, errorMessage: '이미지 경로가 없습니다.'));
        }
        break;

      case 'cameraCanceled':
        _updateState(_state.copyWith(cameraLoading: false, selectedFile: null));
        break;

      case 'cameraError':
        final String? errorMessage = call.arguments as String?;
        _updateState(_state.copyWith(
            cameraLoading: false,
            selectedFile: null,
            errorMessage: errorMessage));
        break;
    }
  }

  Future<void> clearCapturedAsset() async {
    _updateState(_state.copyWith(
        selectedFile: null,
        capturedAsset: null,
        pageViewDisplayItems: _state.selectedImages));
  }

  Future<void> onCameraNavigationDone() async {
    if (_state.cameraLoading) {
      if (_state.capturedAsset != null) {
        _model.removeSelectedImage(state.capturedAsset!);
      }
      _updateState(_state.copyWith(
          selectedImages: _model.selectedImages,
          selectedFile: null,
          cameraLoading: false,
          capturedAsset: null));
      openCamera();
      loadAlbumList(state.requestType.toString());
    }
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

  Future<void> init() async {
    _updateState(_state.copyWith(
        isLoading: true, errorMessage: null, requestType: _model.requestType));
    try {
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

  Future<void> loadAlbumList(String requestType) async {
    switch (requestType) {
      case 'common':
        setRequestType(RequestType.common);
        break;
      case 'image':
        setRequestType(RequestType.image);
        break;
      case 'video':
        setRequestType(RequestType.video);
        break;
    }
    try {
      await _model.loadAlbumList();
      _updateState(_state.copyWith(
          albumList: _model.albumList,
          selectedAlbum: _model.selectedAlbum,
          assetList: _model.assetList));
    } catch (e) {
      _updateState(_state.copyWith(errorMessage: e.toString()));
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

  void setInitialIndexForCameraImage() {
    _updateState(
        _state.copyWith(initialIndex: _state.pageViewDisplayItems.length - 1));
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_state.pageViewDisplayItems.length - 1);
      }
    });
  }

  // 8. 사진 선택 완료 (선택된 사진 목록 반환)
  List<AssetEntity> getSelectedPhotos() {
    return _model.getSelectedPhotos();
  }

  void setGridCount(int count) {
    _model.setPickerGridCount(count);
    _updateState(_state.copyWith(pickerGridCount: count));
  }

  // 선택 색상 설정
  void setSelectedColor(Color color) {
    _model.setSelectedColor(color);
    _updateState(_state.copyWith(selectedColor: color));
  }

  void removeImage(AssetEntity assetImage) {
    _model.removeSelectedImage(assetImage);
    _updateState(_state.copyWith(selectedImages: _model.selectedImages));
  }

  // 선택된 이미지 초기화
  void clearSelectedImages() {
    _model.clearSelectedImages();
    _updateState(_state.copyWith(selectedImages: _model.selectedImages));
  }

  void setRequestType(RequestType requestType) {
    // 추가된 부분
    _model.setRequestType(requestType);
    _updateState(_state.copyWith(requestType: _model.requestType));
  }

  void _updateState(ImagePickerState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    platform.setMethodCallHandler(null);
    _pageController.dispose();
    _btnController.close();
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

  void setPoppedByCode(bool value) {
    _updateState(_state.copyWith(isPoppedByCode: value));
  }
}
