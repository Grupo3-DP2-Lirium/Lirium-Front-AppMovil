import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/config/api_constants.dart';
import 'package:flutter_frontend/data/models/memorial_request.dart';
import 'package:flutter_frontend/data/repositories/memorial_repository_impl.dart';
import 'package:flutter_frontend/presentation/components/buttons/switch_button.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'package:flutter_frontend/presentation/components/forms/date_field.dart';

class InformationMemorialScreen extends StatefulWidget {
  final String relation;

  const InformationMemorialScreen({
    super.key,
    required this.relation,
  });

  @override
  State<InformationMemorialScreen> createState() =>
      _InformationMemorialScreenState();
}

class _InformationMemorialScreenState extends State<InformationMemorialScreen> {
  final TextEditingController _relationController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isCollaborative = false;
  File? _imageController;


  @override
  void initState() {
    super.initState();
    _relationController.text = widget.relation; // setea el vínculo recibido
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppTitle(
                title: "Información y Detalles",
                textAlign: TextAlign.center,
              ),
              // Subir foto
              Center(
                child: ProfileAvatar(
                  radius: 60,
                  showCameraIcon: true,
                  placeholderIcon: Icons.image_outlined,
                  onImageChanged: (file) {
                    setState(() {
                      _imageController = file; // <-- aquí guardas la imagen
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Campos de texto
              AppTextField(
                  controller: _nameController,
                  hintText: "Nombre"),
              const SizedBox(height: 16),

              // Vínculo (solo lectura)
              AppTextField(
                controller: _relationController,
                hintText: "Vínculo",
                enabled: false,
              ),
              const SizedBox(height: 16),

              // Fecha de nacimiento con selector
              DateTextField(
                hintText: "Fecha de nacimiento",
                controller: _birthDateController,
              ),

              const SizedBox(height: 16),

              AppTextField(
                  controller: _nicknameController,
                  hintText: "Apodo"),
              const SizedBox(height: 16),

              AppTextField(
                controller: _descriptionController,
                hintText: "Descripción...",
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Checkbox perfil colaborativo
              Row(
                children: [
                  BooleanSelectorSwitch(
                    label: "Perfil colaborativo",
                    value: _isCollaborative,
                    onChanged: (newValue) {
                      setState(() {
                        _isCollaborative = newValue;
                      });
                    },
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
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryButton(
                      text: "Guardar",
                      onPressed: () async {
                        try {
                          // Ejemplo de token (lo ideal es recuperarlo dinámicamente)
                          const token = "eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiJ0ZXN0QGV4YW1wbGUuY29tIiwiaWF0IjoxNzU4NzcxNjMwLCJleHAiOjE3NTg4NTgwMzB9.yXGZ19x6CM2HfobNj8DwzioKWWtPjT2U5tn7tgcWnPooObRn7Z-uEPvnXb2q9vpl";

                          final request = MemorialRequestModel(
                            name: _nameController.text,
                            gender: "M",
                            relation: "_relationController",
                            birthDate: "2000-06-01",
                            nickname: _nicknameController.text,
                            description: _descriptionController.text,
                            isCollaborative: _isCollaborative,
                            isJournal: false
                          );

                          final repo = MemorialRepositoryImpl(ApiConstants.baseUrl); // usa ApiConstants.baseUrl internamente

                          final memorial = await repo.createMemorial(
                            request,
                            _imageController?.path, // null si no hay imagen
                            token,
                          );

                          // Si llega aquí, se creó correctamente
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Memorial creado correctamente")),
                          );

                          Navigator.pop(context, memorial); // puedes devolver el objeto creado
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error al crear memorial: $e")),
                          );
                        }
                      },
                    ),
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
