import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/reflection_model.dart';

class ReflectionService {
  static const String _reflectionsKey = 'reflections';
  static const String _storageUsageKey = 'storage_usage';
  static const int _maxStorageForFreeUsers = 100 * 1024 * 1024; // 100 MB en bytes

  // Simulamos el tipo de usuario (en una app real vendría del backend)
  UserType _userType = UserType.premium; // Cambiado a premium para testing

  Future<List<ReflectionModel>> getAllReflections() async {
    final prefs = await SharedPreferences.getInstance();
    final reflectionsJson = prefs.getString(_reflectionsKey);
    
    if (reflectionsJson == null) return [];
    
    final List<dynamic> reflectionsList = jsonDecode(reflectionsJson);
    return reflectionsList
        .map((json) => ReflectionModel.fromJson(json))
        .toList()
      ..sort((a, b) => b.createdDate.compareTo(a.createdDate)); // Más recientes primero
  }

  Future<void> saveReflection(ReflectionModel reflection) async {
    final reflections = await getAllReflections();
    
    // Verificar si es una edición o nueva reflexión
    final existingIndex = reflections.indexWhere((r) => r.id == reflection.id);
    if (existingIndex != -1) {
      reflections[existingIndex] = reflection;
    } else {
      reflections.insert(0, reflection); // Agregar al principio
    }
    
    await _saveReflectionsList(reflections);
  }

  Future<void> deleteReflection(String reflectionId) async {
    final reflections = await getAllReflections();
    
    // Encontrar la reflexión para eliminar sus archivos
    final reflection = reflections.firstWhere(
      (r) => r.id == reflectionId,
      orElse: () => throw Exception('Reflexión no encontrada'),
    );
    
    // Eliminar archivos físicos
    for (final file in reflection.attachedFiles) {
      try {
        final fileToDelete = File(file.path);
        if (await fileToDelete.exists()) {
          await fileToDelete.delete();
        }
      } catch (e) {
        print('Error eliminando archivo: $e');
      }
    }
    
    // Eliminar de la lista
    reflections.removeWhere((r) => r.id == reflectionId);
    await _saveReflectionsList(reflections);
    await _updateStorageUsage();
  }

  Future<ReflectionModel?> getReflectionById(String id) async {
    final reflections = await getAllReflections();
    try {
      return reflections.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveReflectionsList(List<ReflectionModel> reflections) async {
    final prefs = await SharedPreferences.getInstance();
    final reflectionsJson = jsonEncode(
      reflections.map((r) => r.toJson()).toList(),
    );
    await prefs.setString(_reflectionsKey, reflectionsJson);
  }

  // Gestión de archivos y almacenamiento
  Future<String> getReflectionsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final reflectionsDir = Directory('${appDir.path}/reflections');
    
    if (!await reflectionsDir.exists()) {
      await reflectionsDir.create(recursive: true);
    }
    
    return reflectionsDir.path;
  }

  Future<ReflectionFile> copyFileToReflectionsDirectory(File sourceFile, ReflectionFileType type) async {
    final reflectionsDir = await getReflectionsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${sourceFile.uri.pathSegments.last}';
    final targetPath = '$reflectionsDir/$fileName';
    
    final copiedFile = await sourceFile.copy(targetPath);
    final fileSize = await copiedFile.length();
    
    return ReflectionFile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      path: targetPath,
      name: sourceFile.uri.pathSegments.last,
      type: type,
      sizeInBytes: fileSize,
    );
  }

  // Verificaciones para usuarios gratuitos
  Future<bool> canAttachFile(int fileSizeInBytes) async {
    if (_userType == UserType.premium) return true;
    
    final currentUsage = await getCurrentStorageUsage();
    return (currentUsage + fileSizeInBytes) <= _maxStorageForFreeUsers;
  }

  Future<int> getCurrentStorageUsage() async {
    final reflections = await getAllReflections();
    int totalSize = 0;
    
    for (final reflection in reflections) {
      for (final file in reflection.attachedFiles) {
        totalSize += file.sizeInBytes;
      }
    }
    
    return totalSize;
  }

  Future<void> _updateStorageUsage() async {
    final usage = await getCurrentStorageUsage();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_storageUsageKey, usage);
  }

  String formatStorageSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  int get maxStorageForFreeUsers => _maxStorageForFreeUsers;
  
  UserType get userType => _userType;
  
  // Método para cambiar tipo de usuario (para testing)
  void setUserType(UserType type) {
    _userType = type;
  }

  // Agrupar reflexiones por mes para la vista
  Future<Map<String, List<ReflectionModel>>> getReflectionsGroupedByMonth() async {
    final reflections = await getAllReflections();
    final Map<String, List<ReflectionModel>> grouped = {};
    
    for (final reflection in reflections) {
      final monthKey = '${reflection.createdDate.year}-${reflection.createdDate.month.toString().padLeft(2, '0')}';
      if (grouped[monthKey] == null) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(reflection);
    }
    
    return grouped;
  }

  String getMonthLabel(DateTime date) {
    const months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${months[date.month]} ${date.year}';
  }

  // Método para generar datos de ejemplo (solo para testing)
  Future<void> generateSampleData() async {
    final sampleReflections = [
      ReflectionModel(
        id: '1',
        title: 'Navidad con mi fam 2 años después',
        content: 'Ha sido un año increíble lleno de aprendizajes y crecimiento personal. '
            'Hoy celebramos la Navidad en familia después de tanto tiempo separados. '
            'Es hermoso ver cómo todos hemos crecido y cambiado, pero el amor sigue siendo el mismo.',
        createdDate: DateTime(2024, 12, 26),
        attachedFiles: [],
      ),
      ReflectionModel(
        id: '2',
        title: '¿Cómo me siento hoy?',
        content: 'Reflexionando sobre el día, me doy cuenta de que he estado más consciente '
            'de mis emociones. A veces es difícil expresar lo que siento, pero escribir '
            'me ayuda a procesar y entender mejor mis pensamientos.',
        createdDate: DateTime(2024, 12, 20),
        attachedFiles: [],
      ),
      ReflectionModel(
        id: '3',
        title: 'Día de visita a la casa de mi infancia',
        content: 'Volví al lugar donde crecí y fue una experiencia muy emotiva. '
            'Los recuerdos vinieron como una avalancha, algunos dulces, otros amargos. '
            'Pero todos han sido parte de mi historia y me han hecho quien soy hoy.',
        createdDate: DateTime(2025, 1, 5),
        attachedFiles: [],
      ),
    ];

    for (final reflection in sampleReflections) {
      await saveReflection(reflection);
    }
  }
}