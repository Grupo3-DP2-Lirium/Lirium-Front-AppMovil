import 'package:flutter/material.dart';
import 'package:flutter_frontend/domain/entities/memory.dart';
import 'package:flutter_frontend/presentation/components/buttons/rectangle_button.dart';
import 'package:flutter_frontend/presentation/components/common/app_title.dart';
import 'package:flutter_frontend/presentation/screens/memories/create_memory_for_a_memorial/select_category.dart';
import 'package:flutter_frontend/presentation/screens/memories/create_memory_for_a_memorial/upload_pictures_and_videos.dart';
import '../memory_details/memory_detail_screen.dart';
import 'write_letter_screen.dart';

class CreateMemorySelectType extends StatefulWidget {
  final String memorialId;
  final String memorialName;
  final bool isFromMemorial;

  const CreateMemorySelectType({super.key,
    required this.memorialId,
    required this.memorialName,
    this.isFromMemorial = false,
  });

  @override
  State<CreateMemorySelectType> createState() => _CreateMemorySelectTypeState();
}

class _CreateMemorySelectTypeState extends State<CreateMemorySelectType> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const SizedBox.shrink(),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const AppTitle(
                    title: "¿Qué vas a hacer hoy?",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Elige una opción",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: [
                      RectangleButton(
                        icon: Icons.photo_camera,
                        label: "Subir fotos y videos",
                        size: 120,
                        onTap: () async {
                          final result = await Navigator.push<Memory>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MemoryDetailScreen(
                                memory: null,
                                mode: MemoryMode.create,
                                memorialId: widget.memorialId,
                              ),
                            ),
                          );

                          // ✅ Solo cerrar SelectType si viene desde memorial
                          if (result != null && mounted && widget.isFromMemorial) {
                            Navigator.pop(context, result);
                          }
                        },
                      ),
                      RectangleButton(
                        icon: Icons.edit,
                        label: "Escribir carta",
                        size: 120,
                        onTap: () async {
                          final result = await Navigator.push<Memory>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WriteLetterScreen(
                                memorialId: widget.memorialId,
                                memorialName: widget.memorialName,
                              ),
                            ),
                          );

                          // ✅ Solo cerrar SelectType si viene desde memorial
                          if (result != null && mounted && widget.isFromMemorial) {
                            Navigator.pop(context, result);
                          }
                        },
                      ),
                      RectangleButton(
                        icon: Icons.monitor_heart,
                        label: "Responder pregunta",
                        size: 120,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SelectCategory(
                                memorialId: widget.memorialId),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
