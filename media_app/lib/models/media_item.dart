import 'dart:io';

enum MediaType {image, video, audio}

class MediaNotFoundException implements Exception {
  final String path;
  MediaNotFoundException(this.path);

  @override
  String toString() => 'No se encontró el archivo en: $path';
}

class MediaItem {
  final String name;
  final String path;
  final MediaType type;
  final DateTime importedAt;
  final int sizeInBytes;

  MediaItem({
    required this.name,
    required this.path,
    required this.type,
    required this.importedAt,
    required this.sizeInBytes,
  });

  factory MediaItem.fromFile(File file, MediaType type) {
    if (!file.existsSync()) {
      throw MediaNotFoundException(file.path);
    }

    final stat = file.statSync();

    return MediaItem(
      name: file.path.split('/').last,
      path: file.path,
      type: type,
      importedAt: stat.modified,
      sizeInBytes: stat.size,
    );
  }

  String get formattedSize {
    final mb = sizeInBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  bool get isPlayable => type == MediaType.video || type == MediaType.audio;

  File get file => File(path);
}
