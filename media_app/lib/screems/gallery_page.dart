import 'package:flutter/material.dart';
import 'package:media_app/screems/media_viewer_page';
import '../models/media_item.dart';
import '../services/media_service.dart';
import '../widgets/media_tile.dart';


class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final _mediaService = MediaService();
  late Future<List<MediaItem>> _mediaFuture;

  @override
  void initState() {
    super.initState();
    _mediaFuture = _mediaService.listMedia();
  }

  void _reload() {
    setState(() {
      _mediaFuture = _mediaService.listMedia();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galería')),
      body: FutureBuilder<List<MediaItem>>(
        future: _mediaFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(child: Text('Todavía no importaste nada'));
          }

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return MediaTile(
                  item: item,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MediaViewerPage(item: item),
                      ),
                    );
                    _reload();
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}