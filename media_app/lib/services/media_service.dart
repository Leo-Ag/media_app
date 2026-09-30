import 'dart:io';
import 'package:media_app/models/media_item.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

class MediaService {
  Future<Directory> get _mediaDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${appDir.path}/media');
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    return mediaDir;
  }

  Future<File> _copyToMediaDirectory(File original) async {
    final mediaDir = await _mediaDirectory;
    final fileName = original.path.split('/').last;
    return original.copy('${mediaDir.path}/$fileName');
  }

  Future<MediaItem?> importFile(MediaType type) async {
    final PlatformFile? picked = await FilePicker.pickFile(
      type: type == MediaType.image
          ? FileType.image
          : type == MediaType.video
              ? FileType.video
              : FileType.audio,
    );

    if (picked == null || picked.path == null) return null;

    final pickedFile = File(picked.path!);
    final savedFile = await _copyToMediaDirectory(pickedFile);
    return MediaItem.fromFile(savedFile, type);
  }

  Future<MediaItem?> captureFromCamera(MediaType type) async {
    final picker = ImagePicker();

    final XFile? captured = type == MediaType.video
        ? await picker.pickVideo(source: ImageSource.camera)
        : await picker.pickImage(source: ImageSource.camera);

    if (captured == null) return null;

    final savedFile = await _copyToMediaDirectory(File(captured.path));
    return MediaItem.fromFile(savedFile, type);
  }

  Future<void> exportFile(MediaItem item) async {
    await Share.shareXFiles([XFile(item.path)]);
  }

  /// Elimina un archivo de la carpeta de la app.
  Future<void> deleteFile(MediaItem item) async {
    final file = item.file;
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<List<MediaItem>> listMedia() async {
    final mediaDir = await _mediaDirectory;
    final entries = mediaDir.listSync().whereType<File>();

    final items = <MediaItem>[];
    for (final file in entries) {
      final type = _typeFromExtension(file.path);
      if (type == null) continue; 
      items.add(MediaItem.fromFile(file, type));
    }

    items.sort((a, b) => b.importedAt.compareTo(a.importedAt));
    return items;
  }

  MediaType? _typeFromExtension(String path) {
    final ext = path.split('.').last.toLowerCase();

    const imageExts = {'jpg', 'jpeg', 'png', 'gif', 'webp'};
    const videoExts = {'mp4', 'mov', 'avi', 'mkv'};
    const audioExts = {'mp3', 'wav', 'm4a', 'aac'};

    if (imageExts.contains(ext)) return MediaType.image;
    if (videoExts.contains(ext)) return MediaType.video;
    if (audioExts.contains(ext)) return MediaType.audio;
    return null;
  }
}