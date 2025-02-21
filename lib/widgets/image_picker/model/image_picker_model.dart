import 'package:photo_manager/photo_manager.dart';

class ImagePickerModel {
  final List<AssetPathEntity> _albumList = [];
  final List<AssetEntity> _assetList = [];
  final List<AssetEntity> _selectedImages = [];
  int _maxSelectableCount = 10;
  int _initialIndex = 0;
  String? _currentAlbumId;
  AssetPathEntity? _selectedAlbum;

  // 불변 리스트 반환
  List<AssetPathEntity> get albumList => List.unmodifiable(_albumList);
  List<AssetEntity> get selectedImages => List.unmodifiable(_selectedImages);
  List<AssetEntity> get assetList => List.unmodifiable(_assetList);
  int get maxSelectableCount => _maxSelectableCount;
  int get initialIndex => _initialIndex;
  String? get currentAlbumId => _currentAlbumId;
  AssetPathEntity? get selectedAlbum => _selectedAlbum;

  Future<void> init() async {
    await loadAlbumList();
    if (_albumList.isNotEmpty) {
        _selectedAlbum = _albumList[0];
        await loadImageFromAlbum(_selectedAlbum!);
    }
  }

  // 1. 앨범 목록 가져오기
  Future<void> loadAlbumList() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      final albumList = await PhotoManager.getAssetPathList(
          type: RequestType.common);
      _albumList.addAll(albumList);
    } else {
      // 권한이 없는 경우, 예외를 발생시키거나, 오류 상태를 설정할 수 있습니다.
      throw Exception("사진 접근 권한이 없습니다.");
    }
  }

  // 2. 앨범 선택
  Future<void> selectAlbum(AssetPathEntity selectedAlbum) async {
    _selectedAlbum = selectedAlbum;
    await loadImageFromAlbum(selectedAlbum);
  }

  // 3. 앨범의 사진 목록 가져오기
  Future<void> loadImageFromAlbum(AssetPathEntity selectedAlbum) async {
    final images = await selectedAlbum.getAssetListRange(
        start: 0, end: await selectedAlbum.assetCountAsync);
    _assetList.clear();
    _assetList.addAll(images);
  }

  // 4. 사진 선택
  void addSelectedImage(AssetEntity image) {
      _selectedImages.add(image);
  }

  // 5. 선택된 사진 제거
  void removeSelectedImage(AssetEntity image) {
    _selectedImages.remove(image);
  }

  // 6. 선택된 사진의 최대 개수 설정
  void setMaxSelectableCount(int count) {
    _maxSelectableCount = count;
  }

  // 7. 전체 화면 사진 보기 (초기 인덱스 설정)
  void setInitialIndexForFullScreen(AssetEntity assetEntity) {
    _initialIndex = assetList.indexOf(assetEntity);
  }

  // 8. 사진 선택 완료 (선택된 사진 목록 반환)
  List<AssetEntity> getSelectedPhotos() {
    _selectedAlbum = albumList[0];
    _assetList.clear();
    return List.unmodifiable(_selectedImages);
  }

  // 9. 선택된 이미지 목록 초기화
  void clearSelectedImages() {
    // _selectedImages.clear();
  }

}
