import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatefulWidget {
  final double radius;
  final bool showCameraIcon;
  final IconData placeholderIcon;

  const ProfileAvatar({
    super.key,
    this.radius = 50,
    this.showCameraIcon = false,
    this.placeholderIcon = Icons.person,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  String? _imagePath;

  Future<void> _pickImage() async {
    // Pide permiso
    var status = await Permission.photos.request(); // o Permission.mediaLibrary / storage según versión
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Se necesita permiso para acceder a la galería")),
      );
      return;
    }

    // Abre el picker
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: widget.radius,
        backgroundColor: Colors.grey[300],
        backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
        child: _imagePath == null
            ? Icon(widget.placeholderIcon, size: widget.radius * 0.6, color: Colors.grey[700])
            : null,
      ),
    );
  }
}
