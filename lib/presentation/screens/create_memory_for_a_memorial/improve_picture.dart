import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/buttons/secondary_button.dart';
import 'package:image_picker/image_picker.dart';

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
      appBar: AppBar(title: const Text("Vista previa")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.file(File(_image!.path), fit: BoxFit.contain),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SecondaryButton(
                  onPressed: () {},
                  text: widget.source == ImageSource.gallery
                        ? "Seleccionar otra foto"
                        : "Volver a tomar",
                ),
                Spacer(),
                PrimaryButton(text: "Mejorar", isFullWidth: false,)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
