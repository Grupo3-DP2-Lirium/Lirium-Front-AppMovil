import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memorial_request.dart';
import 'package:flutter_frontend/data/services/memorial_service.dart';
import 'package:flutter_frontend/presentation/components/buttons/switch_button.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'package:flutter_frontend/presentation/components/forms/date_field.dart';

class InformationMemorialScreen extends StatefulWidget {
  final String relation;

  const InformationMemorialScreen({super.key, required this.relation});

  @override
  State<InformationMemorialScreen> createState() =>
      _InformationMemorialScreenState();
}

class _InformationMemorialScreenState extends State<InformationMemorialScreen> {
  final _nameController = TextEditingController();
  final _relationController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isCollaborative = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _relationController.text = widget.relation;
  }

  Future<void> _saveMemorial() async {
    final token = "eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiJ0ZXN0QGV4YW1wbGUuY29tIiwiaWF0IjoxNzU4OTk2ODAxLCJleHAiOjE3NTkwODMyMDF9.r9HJmd7W_4GM2DfWR0mUnCg9L5XSZoMfRExm0FRjtWTGhqSMOCGOkkyPEGHoa_Zx"; // Recupera dinámicamente en producción
    final service = MemorialService();

    try {
      final memorial = await service.createMemorial(
        MemorialRequestModel(
          name: _nameController.text,
          gender: "M",
          relation: _relationController.text,
          birthDate: "2000-06-01",
          nickname: _nicknameController.text,
          description: _descriptionController.text,
          isCollaborative: _isCollaborative,
          isJournal: false,
        ),
        _imageFile?.path,
        token,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Memorial creado correctamente")),
      );
      Navigator.pop(context, memorial);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al crear memorial: $e")),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller,
      {String hintText = "", bool enabled = true, int maxLines = 1}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: AppTextField(
          controller: controller,
          hintText: hintText,
          enabled: enabled,
          maxLines: maxLines,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppTitle(title: "Información y Detalles", textAlign: TextAlign.center),

              // Avatar
              Center(
                child: ProfileAvatar(
                  radius: 60,
                  showCameraIcon: true,
                  placeholderIcon: Icons.image_outlined,
                  onImageChanged: (file) => setState(() => _imageFile = file),
                ),
              ),

              const SizedBox(height: 16),

              // Campos de texto
              _buildTextField(_nameController, hintText: "Nombre"),
              _buildTextField(_relationController, hintText: "Vínculo", enabled: false),
              DateTextField(hintText: "Fecha de nacimiento", controller: _birthDateController),
              _buildTextField(_nicknameController, hintText: "Apodo"),
              _buildTextField(_descriptionController, hintText: "Descripción...", maxLines: 3),

              // Switch colaborativo
              Row(
                children: [
                  BooleanSelectorSwitch(
                    label: "Perfil colaborativo",
                    value: _isCollaborative,
                    onChanged: (v) => setState(() => _isCollaborative = v),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: "Regresar",
                      textColor: AppColors.primary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryButton(text: "Guardar", onPressed: _saveMemorial),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
