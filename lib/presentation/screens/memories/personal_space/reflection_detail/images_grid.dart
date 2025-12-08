import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter_frontend/data/models/reflection_model.dart';

class ImagesGrid extends StatelessWidget {
  final List<ReflectionFile> images;
  final Function(ReflectionFile) onOpenImage;

  const ImagesGrid({
    super.key,
    required this.images,
    required this.onOpenImage,
  });

  @override
  Widget build(BuildContext context) {
    if (images.length == 1) {
      return _buildSingleImage(context, images.first, 3);
    }



    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length > 4 ? 4 : images.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: images.length >= 4 ? 2 : images.length,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (_, index) {
        if (index == 3 && images.length > 4) {
          return _buildMoreImagesOverlay(context);
        }
        return _buildTile(context, images[index], index);
      },
    );
  }

  Widget _buildTile(BuildContext context, ReflectionFile img, int index) {
    return GestureDetector(
      onTap: () => _showImageCarousel(context, index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _loadImage(img),
      ),
    );
  }

  Widget _buildSingleImage(BuildContext context, ReflectionFile img, int index) {
    return GestureDetector(
      onTap: () => _showImageCarousel(context, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _loadImage(img),
      ),
    );
  }

  void _showImageCarousel(BuildContext context, int initialIndex) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "ImageCarousel",
      pageBuilder: (context, anim1, anim2) {
        return Container(
          color: Colors.black,
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              PageView.builder(
                controller: PageController(initialPage: initialIndex),
                itemCount: images.length,
                itemBuilder: (_, index) {
                  final img = images[index];
                  return GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Center(
                      child: img.localPath != null
                          ? Image.file(File(img.localPath!), fit: BoxFit.contain)
                          : Image.network(img.downloadUrl, fit: BoxFit.contain),
                    ),
                  );
                },
              ),
              Positioned(
                top: 40,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  Widget _buildMoreImagesOverlay(BuildContext context) {
    final remaining = images.length - 3;

    return GestureDetector(
      onTap: () => _showAllImagesDialog(context),
      child: Stack(
        children: [
          _buildTile(context,images[3], 3),
          Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '+$remaining',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllImagesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        final size = MediaQuery.of(context).size;
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.all(8),
          child: SizedBox(
            height: size.height * 0.65,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      // Título centrado
                      const Center(
                        child: Text(
                          'Todas las imágenes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: images.length,
                    itemBuilder: (_, index) {
                      final img = images[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _showImageCarousel(context, index);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _loadImage(img),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _loadImage(ReflectionFile img) {
    if (img.localPath != null) {
      return Image.file(File(img.localPath!), fit: BoxFit.cover);
    }
    if (img.downloadUrl.isNotEmpty) {
      return Image.network(img.downloadUrl, fit: BoxFit.cover);
    }
    return Container(color: Colors.grey.shade200);
  }

}
