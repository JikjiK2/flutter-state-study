import 'dart:io';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

class ImagePickerModel {
  static const platform = MethodChannel('com.example.camera/intent');

  Future<void> openNativeCamera() async {
    try {
      await platform.invokeMethod('openCamera');
    } on PlatformException catch (e) {
      print("카메라 열기 실패: '${e.message}'.");
    }
  }

  Future<void> openNativeVideoCamera() async {
    try {
      await platform.invokeMethod('openVideoCamera');
    } on PlatformException catch (e) {
      print("동영상 카메라 열기 실패: '${e.message}'.");
    }
  }

  Future<PermissionState> requestPhotoPermission() async {
    return await PhotoManager.requestPermissionExtend();
  }

  Future<List<AssetPathEntity>> fetchAlbumList(RequestType requestType) async {
    final permission = await requestPhotoPermission();
    if (permission.isAuth) {
      final albumList = await PhotoManager.getAssetPathList(type: requestType);
      return albumList;
    } else {
      throw Exception("사진 접근 권한이 없습니다.");
    }
  }

  Future<List<AssetEntity>> fetchAssetsForAlbum(AssetPathEntity album) async {
    return await album.getAssetListRange(
        start: 0, end: await album.assetCountAsync);
  }

  Future<AssetEntity?> handleCapturedImage(String imagePath) async {
    try {
      final AssetEntity? newAsset;
      newAsset = await PhotoManager.editor.saveImageWithPath(
        imagePath,
        title: imagePath.split('/').last,
      );
      if (newAsset != null) {
        return newAsset;
      } else {
        print("이미지 생성 실패 - $imagePath");
        return null;
      }
    } catch (e) {
      print("이미지 저장/처리 오류 - $e");
      return null;
    }
  }

  Future<AssetEntity?> handleCapturedVideo(String videoPath) async {
    try {
      final AssetEntity? newAsset;
      final File videoFile = File(videoPath);
      newAsset = await PhotoManager.editor.saveVideo(
        videoFile,
        title: videoPath.split('/').last,
      );
      if (newAsset != null) {
        return newAsset;
      } else {
        print("동영상 생성 실패 - $videoPath");
        return null;
      }
    } catch (e) {
      print("동영상 저장/처리 오류 - $e");
      return null;
    }
  }
}
