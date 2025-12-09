import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/selection/list_selector.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_frontend/data/models/memorial_request.dart';
import 'package:flutter_frontend/data/services/memorial_service.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'package:flutter_frontend/presentation/components/common/app_pop_up.dart';
import 'package:flutter_frontend/presentation/components/inputs/custom_text_field.dart';
import 'package:flutter_frontend/presentation/components/inputs/custom_date_field.dart';
import 'package:flutter_frontend/presentation/components/inputs/custom_text_area.dart';
import 'package:flutter_frontend/presentation/components/inputs/custom_dropdown_field.dart';
import 'package:flutter_frontend/presentation/components/buttons/switch_button.dart';

class EditMemorialScreen extends StatefulWidget {
  final String memorialId;

  const EditMemorialScreen({
    super.key,
    required this.memorialId,
  });

  @override
  State<EditMemorialScreen> createState() => _EditMemorialScreenState();
}

class _EditMemorialScreenState extends State<EditMemorialScreen> {
  final MemorialService _service = MemorialService();

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _relationController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _genderController = TextEditingController();

  // Estado para fecha y colaborativo
  DateTime? _birthDate;
  bool _isCollaborative = false;

  // Image selected for the profile avatar
  File? _imageFile;
  String? _currentImageUrl;

  // Form key used for validation
  final _formKey = GlobalKey<FormState>();

  // Loading state
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMemorialData();
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

  /// Carga los datos del memorial desde el backend
  Future<void> _loadMemorialData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final memorial = await _service.getMemorialById(widget.memorialId);

      setState(() {
        _nameController.text = memorial.name;
        _relationController.text = memorial.relation;
        _nicknameController.text = memorial.nickname;
        _descriptionController.text = memorial.description;
        _genderController.text = memorial.gender;
        _isCollaborative = memorial.isCollaborative;

        // Parsear fecha de yyyy-MM-dd a DateTime
        if (memorial.birthDate.isNotEmpty) {
          final parts = memorial.birthDate.split('-');
          if (parts.length == 3) {
            _birthDate = DateTime(
              int.parse(parts[0]), // year
              int.parse(parts[1]), // month
              int.parse(parts[2]), // day
            );
          }
        }

        // Guardar URL de imagen actual
        _currentImageUrl = memorial.profilePhoto?.fileUrl;

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los datos del memorial: $e';
        _isLoading = false;
      });
    }
  }

  /// Obtiene la imagen a mostrar en el avatar
  ImageProvider? _getAvatarImage() {
    // Si hay una nueva imagen seleccionada
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    }

    // Si hay una imagen actual del servidor
    if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      // Verificar si es base64
      if (_currentImageUrl!.startsWith('data:image') || _currentImageUrl!.length > 500) {
        try {
          final base64String = _currentImageUrl!.contains(',')
              ? _currentImageUrl!.split(',').last
              : _currentImageUrl!;
          return MemoryImage(base64Decode(base64String));
        } catch (e) {
          print('Error decoding base64 image: $e');
          return null;
        }
      } else {
        // Es una URL normal
        return NetworkImage(_currentImageUrl!);
      }
    }

    return null;
  }

  /// Handles the submission of the form
  Future<void> _saveMemorial() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Formatear fecha de DateTime a yyyy-MM-dd
    String formattedBirthDate = '';
    if (_birthDate != null) {
      final y = _birthDate!.year.toString().padLeft(4, '0');
      final m = _birthDate!.month.toString().padLeft(2, '0');
      final d = _birthDate!.day.toString().padLeft(2, '0');
      formattedBirthDate = "$y-$m-$d";
    }

    try {
      // Pop-up de Cargando
      appPopupButtonDefault(
        context: context,
        title: "",
        message: "",
        buttons: [AppPopupButton(text: "", onPressed: () {})],
        isLoading: true,
      );

      await _service.updateMemorial(
        widget.memorialId,
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

      // Mostrar pop-up de éxito
      await appPopupButtonDefault(
        context: context,
        title: "¡Memorial actualizado!",
        message: "Los cambios han sido guardados correctamente",
        buttons: [
          AppPopupButton(
            text: "Continuar",
            onPressed: () {
              Navigator.pop(context); // cierra el pop-up
              Navigator.pop(context, true); // retrocede con resultado
            },
          ),
        ],
      );
    } catch (e) {
      Navigator.pop(context); // cerrar loading si hubo error

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar memorial: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Si está cargando, mostrar indicador
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    // Si hay error, mostrar mensaje
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadMemorialData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Define form fields con los componentes estandarizados
    final List<Widget> fields = [
      // Nombre
      CustomTextField(
        label: 'Nombre',
        controller: _nameController,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'El nombre es obligatorio';
          }
          return null;
        },
      ),

      // Vínculo
      AppDropdownField(
        controller: _relationController,
        header: 'Vínculo',
        options: const ['Familia', 'Amigo', 'Mascota', 'Pareja', 'Otro'],
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'El tipo de relación es obligatorio';
          }
          return null;
        },
      ),

      // Género
      AppDropdownField(
        controller: _genderController,
        header: 'Género',
        options: const ['Masculino', 'Femenino', 'Otro'],
        validator: (val) {
          if (val == null || val.trim().isEmpty) {
            return 'El género es obligatorio';
          }
          return null;
        },
      ),

      // Fecha de nacimiento
      CustomDateField(
        label: 'Fecha de nacimiento',
        value: _birthDate,
        onChanged: (date) => setState(() => _birthDate = date),
        validator: (date) {
          if (date == null) {
            return 'La fecha de nacimiento es obligatoria';
          }
          return null;
        },
      ),

      // Apodo
      CustomTextField(
        label: 'Apodo',
        controller: _nicknameController,
      ),

      // Descripción
      CustomTextArea(
        label: 'Descripción',
        controller: _descriptionController,
        maxLines: 3,
        maxLength: 200,
      ),

      // Switch colaborativo
      BooleanSelectorSwitch(
        label: "Perfil colaborativo",
        value: _isCollaborative,
        onChanged: (v) => setState(() => _isCollaborative = v),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
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
                      // Título
                      const Center(
                        child: AppTitle(title: "Editar información"),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Avatar con funcionalidad de cambio de foto
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: screenWidth * 0.3,
                              height: screenWidth * 0.3,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[200],
                                image: _getAvatarImage() != null
                                    ? DecorationImage(
                                  image: _getAvatarImage()!,
                                  fit: BoxFit.cover,
                                )
                                    : null,
                              ),
                              child: _getAvatarImage() == null
                                  ? Icon(
                                Icons.image_outlined,
                                size: screenWidth * 0.12,
                                color: Colors.grey[400],
                              )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  // Usar ProfileAvatar para seleccionar imagen
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Cambiar foto'),
                                      content: ProfileAvatar(
                                        radius: 60,
                                        showCameraIcon: true,
                                        placeholderIcon: Icons.image_outlined,
                                        onImageChanged: (file) {
                                          setState(() => _imageFile = file);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
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

            // Footer buttons: "Regresar" y "Guardar"
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