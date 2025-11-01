import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_frontend/data/models/memorial_request.dart';
import 'package:flutter_frontend/data/services/memorial_service.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'package:flutter_frontend/presentation/components/forms/date_field.dart';
import 'package:flutter_frontend/presentation/components/selection/list_selector.dart';

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
  final ImagePicker _picker = ImagePicker();

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _relationController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _genderController = TextEditingController();

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
    _birthDateController.dispose();
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

        // Formatear fecha de yyyy-MM-dd a dd/MM/yyyy
        if (memorial.birthDate.isNotEmpty) {
          final parts = memorial.birthDate.split('-');
          if (parts.length == 3) {
            _birthDateController.text = '${parts[2]}/${parts[1]}/${parts[0]}';
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

  /// Muestra el selector de fuente de imagen (cámara o galería)
  Future<void> _showImageSourceActionSheet() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Barra superior indicadora
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Título
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Seleccionar foto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                
                const Divider(),
                
                // Opción: Tomar foto
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFF6366F1),
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    'Tomar foto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                
                // Opción: Elegir de galería
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Color(0xFF6366F1),
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    'Elegir de galería',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Selecciona una imagen de la fuente especificada
  Future<void> _pickImage(ImageSource source) async {
    try {
      // Pedir permisos según la fuente
      if (source == ImageSource.camera) {
        final cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          _showPermissionDeniedMessage('cámara');
          return;
        }
      } else if (source == ImageSource.gallery) {
        final storageStatus = await Permission.photos.request(); // iOS
        final androidStatus = await Permission.storage.request(); // Android
        if (!storageStatus.isGranted && !androidStatus.isGranted) {
          _showPermissionDeniedMessage('galería');
          return;
        }
      }

      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Muestra mensaje cuando se niegan los permisos
  void _showPermissionDeniedMessage(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Se necesita permiso de $type para esta función'),
        action: SnackBarAction(
          label: 'Configuración',
          onPressed: () => openAppSettings(),
        ),
      ),
    );
  }

  /// Handles the submission of the form
  Future<void> _saveMemorial() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Formatear fecha de dd/MM/yyyy a yyyy-MM-dd
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
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6366F1),
          ),
        ),
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
          isCollaborative: false, // Por defecto
          isJournal: false,
        ),
        _imageFile?.path,
      );

      // Cerrar el diálogo de carga
      Navigator.pop(context);

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Memorial actualizado exitosamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Retornar true para indicar que se guardó correctamente
      Navigator.pop(context, true);
    } catch (e) {
      // Cerrar el diálogo de carga si está abierto
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar memorial: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Si está cargando, mostrar indicador
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6366F1),
          ),
        ),
      );
    }

    // Si hay error, mostrar mensaje
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
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
                    backgroundColor: const Color(0xFF6366F1),
                  ),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
      AppDropdownField(
        controller: _relationController,
        options: const ["Familia", "Amigo", "Mascota", "Pareja", "Otro"],
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'El tipo de relación es obligatorio';
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
      _buildTextField(
        _descriptionController,
        hintText: "Descripción...",
        maxLines: 5,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar información',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Avatar con funcionalidad de cambio de foto
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: screenWidth * 0.25,
                              height: screenWidth * 0.25,
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
                                      Icons.person,
                                      size: screenWidth * 0.12,
                                      color: Colors.grey[400],
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _showImageSourceActionSheet,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF6366F1),
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
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: _showImageSourceActionSheet,
                          child: const Text(
                            'Cambiar foto',
                            style: TextStyle(
                              color: Color(0xFF6366F1),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.02),
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
          ],
        ),
      ),
    );
  }
}
