import 'dart:io';
import 'package:flutter/material.dart';
import '../models/media_item.dart';

/// Representa un solo elemento dentro del grid de la galería.
/// No sabe qué pasa al tocarlo: eso lo decide quien lo usa (onTap).
class MediaTile extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onTap;

  const MediaTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Para imágenes, mostramos el archivo directamente.
            // Para video/audio, mostramos un ícono en vez de un thumbnail real
            // (generar miniaturas de video requeriría un paquete aparte).
            if (item.type == MediaType.image)
              Image.file(File(item.path), fit: BoxFit.cover)
            else
              Container(
                color: Colors.grey[300],
                child: Icon(
                  item.type == MediaType.video
                      ? Icons.videocam
                      : Icons.audiotrack,
                  size: 40,
                  color: Colors.grey[700],
                ),
              ),

            // Franja inferior con el nombre del archivo.
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                child: Text(
                  item.name,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}