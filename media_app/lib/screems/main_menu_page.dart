import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../services/media_service.dart';
import 'gallery_page.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaService = MediaService();

    return Scaffold(
      appBar: AppBar(title: const Text('Mi galería local')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Ver galería'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GalleryPage()),
              ),
            ),

            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.file_upload),
              label: const Text('Importar archivo'),
              onPressed: () => _importFile(context, mediaService),
            ),

            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tomar foto'),
              onPressed: () => _capture(context, mediaService, MediaType.image),
            ),

            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.videocam),
              label: const Text('Grabar video'),
              onPressed: () => _capture(context, mediaService, MediaType.video),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importFile(BuildContext context, MediaService service) async {
    final type = await _askMediaType(context);
    if (type == null) return; 

    final item = await service.importFile(type);
    if (item != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Importado: ${item.name}')));
    }
  }

  Future<void> _capture(
    BuildContext context,
    MediaService service,
    MediaType type,
  ) async {
    final item = await service.captureFromCamera(type);
    if (item != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Capturado: ${item.name}')));
    }
  }

  Future<MediaType?> _askMediaType(BuildContext context) {
    return showDialog<MediaType>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('¿Qué querés importar?'),
        children: [
          SimpleDialogOption(
            child: const Text('Imagen'),
            onPressed: () => Navigator.pop(context, MediaType.image),
          ),
          SimpleDialogOption(
            child: const Text('Video'),
            onPressed: () => Navigator.pop(context, MediaType.video),
          ),
          SimpleDialogOption(
            child: const Text('Audio'),
            onPressed: () => Navigator.pop(context, MediaType.audio),
          ),
        ],
      ),
    );
  }
}
