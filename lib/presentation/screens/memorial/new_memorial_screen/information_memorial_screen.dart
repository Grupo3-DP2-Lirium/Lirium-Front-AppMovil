import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memorial_request.dart';
import 'package:flutter_frontend/data/services/memorial_service.dart';
import 'package:flutter_frontend/presentation/components/buttons/switch_button.dart';
import 'package:flutter_frontend/presentation/components/common/app_pop_up.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'package:flutter_frontend/presentation/components/forms/date_field.dart';
import 'package:flutter_frontend/presentation/components/inputs/custom_date_field.dart';
import 'package:flutter_frontend/presentation/components/inputs/custom_dropdown_field.dart';
import 'package:flutter_frontend/presentation/components/inputs/custom_text_area.dart';
import 'package:flutter_frontend/presentation/components/inputs/custom_text_field.dart';
import 'package:flutter_frontend/presentation/components/selection/list_selector.dart';
import 'package:flutter_frontend/presentation/screens/memorial/new_memorial_screen/memorial_created_screen.dart';
import 'package:flutter_frontend/providers/memorial_provider.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../../../components/common/app_bar.dart';

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
  final _nicknameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _genderController = TextEditingController();


  // Estado para dropdown y fecha:
  String? _selectedGender;
  DateTime? _birthDate;

  // Boolean for collaborative profile switch
  bool _isCollaborative = false;

  // Image selected for the profile avatar
  File? _imageFile;

  // Form key used for validation
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _relationController.text = widget.relation;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationController.dispose();
    _nicknameController.dispose();
    _descriptionController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  /// Handles the submission of the form and sends the data to the backend
  Future<void> _saveMemorial() async {
    final service = MemorialService();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Pop-up de Cargando
    appPopupButtonDefault(
      context: context,
      title: "",
      message: "",
      buttons: [AppPopupButton(text: "", onPressed: () {})],
      isLoading: true,
    );

    String formattedBirthDate = '';
    if (_birthDate != null) {
      final y = _birthDate!.year.toString().padLeft(4, '0');
      final m = _birthDate!.month.toString().padLeft(2, '0');
      final d = _birthDate!.day.toString().padLeft(2, '0');
      formattedBirthDate = "$y-$m-$d";
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

        _imageFile?.path,
      );

      Navigator.pop(context); // cerrar loading

      // Actualizar provider
      final provider = Provider.of<MemorialProvider>(context, listen: false);
      provider.agregarMemorial(memorial);

      // Mostrar pop-up de éxito
      await appPopupButtonDefault(
        context: context,
        title: "¡Memorial creado!",
        message: "Tu memorial ha sido creado correctamente",
        buttons: [
          AppPopupButton(
            text: "Continuar",
            onPressed: () {
              Navigator.pop(context); // cierra el pop-up
              Navigator.pop(context); // retrocede al listado
            },
          ),
        ],
      );
    } catch (e) {
      Navigator.pop(context); // cerrar loading si hubo error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al crear memorial: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      // Nombre
      CustomTextField(
        label: 'Nombre',
        controller: _nameController,
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'El nombre es obligatorio';
          return null;
        },
      ),

      // Vínculo (solo lectura)
      CustomTextField(
        label: 'Vínculo',
        controller: _relationController,
        enabled: false,
        readOnly: true,
      ),

      // Género
      AppDropdownField(
        controller: _genderController,
        header: 'Género',
        options: ['Masculino', 'Femenino', 'Otro'],
        validator: (val) {
          if (val == null || val.trim().isEmpty) return 'El género es obligatorio';
          return null;
        },
      ),

      // Fecha de nacimiento -> CustomDateField
      CustomDateField(
        label: 'Fecha de nacimiento',
        value: _birthDate,
        onChanged: (date) => setState(() => _birthDate = date),
        validator: (date) {
          if (date == null) return 'La fecha de nacimiento es obligatoria';
          return null;
        },
      ),

      // Apodo
      CustomTextField(
        label: 'Apodo',
        controller: _nicknameController,
      ),

      // Descripción -> CustomTextArea
      CustomTextArea(
        label: 'Descripción',
        controller: _descriptionController,
        maxLines: 3,
        maxLength: 200,
      ),

      // Switch colaborativo
      BooleanSelectorSwitch(
        label: "Memorial sea colaborativo",
        value: _isCollaborative,
        onChanged: (v) => setState(() => _isCollaborative = v),
      ),
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = screenHeight * 0.09;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMemoryAppBar(
        title: "Información y Detalles",
        onBack: () => Navigator.pop(context),
        appBarHeight:appBarHeight,
        showBackButton: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
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
                      SizedBox(height: screenHeight * 0.03),
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
                        padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                        child: field,
                      )),
                    ],
                  ),
                ),
              ),
            ),
            // Footer buttons: "Back" and "Save"
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: screenHeight * 0.01,
                  top: screenHeight * 0.02,
                ),
                child: Row(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}