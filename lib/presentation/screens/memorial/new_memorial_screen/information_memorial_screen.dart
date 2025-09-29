import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memorial_request.dart';
import 'package:flutter_frontend/data/services/memorial_service.dart';
import 'package:flutter_frontend/presentation/components/buttons/switch_button.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'package:flutter_frontend/presentation/components/forms/date_field.dart';
import 'package:flutter_frontend/presentation/components/selection/list_selector.dart';
import 'package:flutter_frontend/presentation/screens/memorial/new_memorial_screen/memorial_created_screen.dart';

class InformationMemorialScreen extends StatefulWidget {
  final String relation;

  const InformationMemorialScreen({super.key, required this.relation});

  @override
  State<InformationMemorialScreen> createState() =>
      _InformationMemorialScreenState();
}

/// Screen for entering information about the memorial.
class _InformationMemorialScreenState extends State<InformationMemorialScreen> {
  // Controllers for form fields
  final _nameController = TextEditingController();
  final _relationController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _genderController = TextEditingController();

  // Boolean for collaborative profile switch
  bool _isCollaborative = false;

  // Image selected for the profile avatar
  File? _imageFile;

  // Form key used for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _relationController.text = widget.relation;
  }

  /// Handles the submission of the form and sends the data to the backend
  Future<void> _saveMemorial() async {
    final service = MemorialService();
    if (!_formKey.currentState!.validate()) {
      return;
    }

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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MemorialCreatedScreen(memorial: memorial),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al crear memorial: $e")),
      );
    }
  }

  /// Helper to build custom text fields with optional validation
  Widget _buildTextField(
      TextEditingController controller, {
        String hintText = "",
        bool enabled = true,
        int maxLines = 1,
        String? Function(String?)? validator,
      }) {
    return AppTextField(
      controller: controller,
      hintText: hintText,
      enabled: enabled,
      maxLines: maxLines,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define form fields with validation where required
    final List<Widget> fields = [
      _buildTextField(
        _nameController,
        hintText: "Nombre",
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'El nombre es obligatorio';
          }
          return null;
        },
      ),
      _buildTextField(
        _relationController,
        hintText: "Vínculo",
        enabled: false,
      ),
      AppDropdownField(
        controller: _genderController,
        options: ["Masculino", "Femenino", "Otro"],
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'El género es obligatorio';
          }
          return null;
        },
      ),
      DateTextField(
        hintText: "Fecha de nacimiento",
        controller: _birthDateController,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'La fecha de nacimiento es obligatoria';
          }
          return null;
        },
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
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: AppTitle(title: "Información y Detalles"),
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
                      // Form fields with spacing
                      ...fields.map((field) => Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                        child: field,
                      )),
                    ],
                  ),
                ),
              ),
            ),
            // Footer buttons: "Back" and "Save"
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