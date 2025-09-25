import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/buttons/secondary_button.dart';
import 'package:image_picker/image_picker.dart';
import 'image_improvement_screen.dart';

class ImprovePicture extends StatefulWidget {
  final ImageSource source;
  const ImprovePicture({super.key, required this.source});

  @override
  State<ImprovePicture> createState() => _ImprovePictureState();
}

class _ImprovePictureState extends State<ImprovePicture> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _pickImage();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: widget.source);
    if (mounted) {
      setState(() {
        _image = image;
        _loading = false;
      });
    }
  }

  void _selectNewImage() {
    setState(() => _loading = true);
    _pickImage();
  }

  void _startImageImprovement() {
    if (_image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageImprovementScreen(imagePath: _image!.path),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_image == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("No seleccionaste ninguna imagen")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vista previa"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Imagen con padding controlado
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_image!.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          
          // Botones con espacio optimizado
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    onPressed: _selectNewImage,
                    text: widget.source == ImageSource.gallery
                        ? "Cambiar foto"
                        : "Repetir",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    text: "Mejorar",
                    onPressed: _startImageImprovement,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
