import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class GalleryService {
  static Future<bool> requestPermissions() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      final result = await Permission.photos.request();
      return result.isGranted;
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return false;
  }

  static Future<bool> hasPermissions() async {
    final status = await Permission.photos.status;
    return status.isGranted;
  }

  static Future<List<AssetEntity>> fetchImages({
    int count = 20,
    int offset = 0,
  }) async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) return [];

    final album = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
      ),
    );

    if (album.isEmpty) return [];

    final firstAlbum = album.first;
    final assets = await firstAlbum.getAssetListPaged(
      page: offset,
      size: count,
    );

    return assets;
  }

  /// Получение миниатюры в виде Uint8List (для Image.memory)
  static Future<Uint8List?> getThumbnailBytes(AssetEntity asset, {int width = 300}) async {
    return await asset.thumbnailDataWithSize(ThumbnailSize(width, width));
  }

  static Future<File?> getFullFile(AssetEntity asset) async {
    return await asset.file;
  }

  static Future<bool> deleteImage(AssetEntity asset) async {
    try {
      final ids = await PhotoManager.editor.deleteWithIds([asset.id]);
      return ids.isNotEmpty;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getMetadata(AssetEntity asset) async {
    final file = await asset.file;
    final size = await file?.length() ?? 0;
    final createTime = asset.createDateTime;

    return {
      'size': size,
      'sizeFormatted': _formatFileSize(size),
      'createTime': createTime,
    };
  }

  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}