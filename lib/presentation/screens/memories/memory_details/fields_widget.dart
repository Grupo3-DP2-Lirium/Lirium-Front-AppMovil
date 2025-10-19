import 'package:flutter/material.dart';
import 'package:flutter_frontend/domain/entities/memory.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'package:intl/intl.dart';

class MemoryFormulario extends StatelessWidget {
  final Memory memory;
  final bool isEditing;
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const MemoryFormulario({
    super.key,
    required this.memory,
    required this.isEditing,
    required this.titleController,
    required this.descriptionController,
  });

  // ------------------- Metadata -------------------
  Widget _buildMetaData() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (memory.photoDate != null)
              Text(
                DateFormat('dd/MM/yy').format(memory.photoDate!),
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (memory.location != null)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.inactive,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 18, color: Colors.redAccent),
                    const SizedBox(width: 4),
                    Text(
                      memory.location!,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ------------------- Formulario -------------------
  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (memory.associatedQuestion != null &&
              memory.associatedQuestion!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AppTextField(
                controller:
                TextEditingController(text: memory.associatedQuestion),
                enabled: false,
                hintText: 'Pregunta Default',
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AppTextField(
                hintText: "Escribe un título",
                controller: titleController,
                enabled: isEditing,
                validator: (v) =>
                (v == null || v.isEmpty) ? "El título es obligatorio" : null,
              ),
            ),
          AppTextField(
            hintText: "Escribe una descripción",
            maxLines: 10,
            controller: descriptionController,
            enabled: isEditing,
            validator: (v) =>
            (v == null || v.isEmpty) ? "La descripción es obligatoria" : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMetaData(),
        _buildForm(),
      ],
    );
  }
}
