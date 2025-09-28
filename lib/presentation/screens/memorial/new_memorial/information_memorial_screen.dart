import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memorial_request.dart';
import 'package:flutter_frontend/data/services/memorial_service.dart';
import 'package:flutter_frontend/presentation/components/buttons/switch_button.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'package:flutter_frontend/presentation/components/forms/date_field.dart';
import 'package:flutter_frontend/presentation/components/selection/list_selector.dart';

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
  final _genderController = TextEditingController();

  bool _isCollaborative = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _relationController.text = widget.relation;
  }

  Future<void> _saveMemorial() async {
    final token =
        "eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiJ0ZXN0QGV4YW1wbGUuY29tIiwiaWF0IjoxNzU4OTk2ODAxLCJleHAiOjE3NTkwODMyMDF9.r9HJmd7W_4GM2DfWR0mUnCg9L5XSZoMfRExm0FRjtWTGhqSMOCGOkkyPEGHoa_Zx";
    final service = MemorialService();

    String formattedBirthDate = '';
    if (_birthDateController.text.isNotEmpty) {
      final parts = _birthDateController.text.split('/'); // "dd/MM/yyyy"
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        formattedBirthDate = "$year-$month-$day"; // "yyyy-MM-dd"
      }
    }

    try {
      final memorial = await service.createMemorial(
        MemorialRequestModel(
          name: _nameController.text,
          gender: _genderController.text,
          relation: _relationController.text,
          birthDate: formattedBirthDate,
          nickname: _nicknameController.text,
          description: _descriptionController.text,
          isCollaborative: _isCollaborative,
          isJournal: false,
        ),
        _imageFile?.path
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
      {String hintText = "", bool enabled = true, int maxLines = 1}) {
    return AppTextField(
      controller: controller,
      hintText: hintText,
      enabled: enabled,
      maxLines: maxLines,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> fields = [
      _buildTextField(_nameController, hintText: "Nombre"),
      _buildTextField(_relationController, hintText: "Vínculo", enabled: false),
      AppDropdownField(
        controller: _genderController,
        options: ["Masculino", "Femenino", "Otro"],
      ),
      DateTextField(
        hintText: "Fecha de nacimiento",
        controller: _birthDateController,
      ),
      _buildTextField(_nicknameController, hintText: "Apodo"),
      _buildTextField(_descriptionController, hintText: "Descripción...", maxLines: 3),
      BooleanSelectorSwitch(
        label: "Perfil colaborativo",
        value: _isCollaborative,
        onChanged: (v) => setState(() => _isCollaborative = v),
      ),
    ];
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.03,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: const AppTitle(
                        title: "Información y Detalles",
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Center(
                      child: ProfileAvatar(
                        radius: screenWidth * 0.15,
                        showCameraIcon: true,
                        placeholderIcon: Icons.image_outlined,
                        onImageChanged: (file) => setState(() => _imageFile = file),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    ...fields.map((field) => Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                      child: field,
                    )),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: "Regresar",
                    textColor: AppColors.primary,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: PrimaryButton(
                    text: "Guardar",
                    onPressed: _saveMemorial,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}