import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileAvatar extends StatefulWidget {
  final double radius;
  final IconData? placeholderIcon;
  final bool showCameraIcon;

  /// Opcional: callback cuando cambia la imagen
  final void Function(File?)? onImageChanged;

  const ProfileAvatar({
    super.key,
    this.radius = 30,
    this.placeholderIcon,
    this.showCameraIcon = false,
    this.onImageChanged,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    // Pedir permisos según la fuente
    if (source == ImageSource.camera) {
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) return;
    } else if (source == ImageSource.gallery) {
      final storageStatus = await Permission.photos.request(); // iOS
      final androidStatus = await Permission.storage.request(); // Android
      if (!storageStatus.isGranted && !androidStatus.isGranted) return;
    }

    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      if (widget.onImageChanged != null) {
        widget.onImageChanged!(_imageFile);
      }
    }
  }

  Future<void> _showImageSourceActionSheet() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de galería'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showImageSourceActionSheet,
      child: Stack(
        children: [
          CircleAvatar(
            radius: widget.radius,
            backgroundColor: Colors.grey[300],
            backgroundImage:
            _imageFile != null ? FileImage(_imageFile!) : null,
            child: _imageFile == null
                ? Icon(
              widget.placeholderIcon ?? Icons.person,
              color: Colors.grey,
              size: widget.radius * 0.8,
            )
                : null,
          ),
          if (widget.showCameraIcon)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: widget.radius * 0.6,
                height: widget.radius * 0.6,
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: widget.radius * 0.3,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
