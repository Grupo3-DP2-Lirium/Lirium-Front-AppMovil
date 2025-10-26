import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/reflection_model.dart';
import 'reflection_api_service.dart';

class ReflectionService {
  static const int _maxStorageForFreeUsers = 100 * 1024 * 1024; // 100 MB en bytes

  final ReflectionApiService _apiService = ReflectionApiService();
  
  // Simulamos el tipo de usuario (en una app real vendría del backend)
  UserType _userType = UserType.premium;

  Future<List<ReflectionModel>> getAllReflections() async {
    try {
      return await _apiService.getReflections();
    } catch (e) {
      print('Error obteniendo reflexiones de API: $e');
      return [];
    }
  }

  Future<ReflectionModel?> saveReflection(ReflectionModel reflection) async {
    try {
      // Verificar si es un UUID válido del backend
      bool isValidBackendId = _isValidUUID(reflection.id);
      
      if (reflection.id.isEmpty || !isValidBackendId) {
        // Crear nueva reflexión - ID vacío o ID generado por frontend
        print('🆕 Creando nueva reflexión (ID: ${reflection.id})');
        
        final result = await _apiService.createReflection(
          title: reflection.title,
          content: reflection.content,
          latitude: reflection.latitude,
          longitude: reflection.longitude,
          files: await _prepareFiles(reflection.attachedFiles),
        );
        
        if (result != null) {
          print('✅ Reflexión creada con UUID del backend: ${result.id}');
          return result;
        } else {
          print('❌ Error creando reflexión');
          return null;
        }
      } else {
        // Actualizar reflexión existente - ID es un UUID válido del backend
        print('📝 Actualizando reflexión existente (UUID: ${reflection.id})');
        
        final result = await _apiService.updateReflection(
          id: reflection.id,
          title: reflection.title,
          content: reflection.content,
          latitude: reflection.latitude,
          longitude: reflection.longitude,
          newFiles: await _prepareFiles(reflection.attachedFiles),
        );
        
        if (result != null) {
          print('✅ Reflexión actualizada exitosamente');
          return result;
        } else {
          print('❌ Error actualizando reflexión');
          return null;
        }
      }
    } catch (e) {
      print('❌ Error en saveReflection: $e');
      return null;
    }
  }

  // Método helper para verificar si un ID es un UUID válido
  bool _isValidUUID(String id) {
    if (id.isEmpty) return false;
    
    // Un UUID tiene el formato: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
    );
    
    return uuidRegex.hasMatch(id);
  }

  // Preparar archivos para envío al backend
  Future<List<File>> _prepareFiles(List<ReflectionFile> attachedFiles) async {
    List<File> files = [];
    
    for (ReflectionFile reflectionFile in attachedFiles) {
      if (reflectionFile.localPath != null && reflectionFile.localPath!.isNotEmpty) {
        File file = File(reflectionFile.localPath!);
        if (await file.exists()) {
          files.add(file);
        }
      }
    }
    
    return files;
  }

  Future<bool> deleteReflection(String reflectionId) async {
    try {
      return await _apiService.deleteReflection(reflectionId);
    } catch (e) {
      print('Error eliminando reflexión de API: $e');
      return false;
    }
  }

  Future<ReflectionModel?> getReflectionById(String id) async {
    try {
      return await _apiService.getReflection(id);
    } catch (e) {
      print('Error obteniendo reflexión de API: $e');
      return null;
    }
  }

  // Métodos para compatibilidad con archivos multimedia
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
    final originalName = sourceFile.uri.pathSegments.last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$originalName';
    final targetPath = '$reflectionsDir/$fileName';
    
    final copiedFile = await sourceFile.copy(targetPath);
    final fileSize = await copiedFile.length();
    
    // Determinar el tipo MIME basado en la extensión
    String fileType = _getFileTypeFromExtension(originalName);
    
    return ReflectionFile.fromLocalFile(
      localPath: targetPath,
      originalName: originalName,
      fileType: fileType,
      fileSize: fileSize,
    );
  }
  
  String _getFileTypeFromExtension(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'mp3':
        return 'audio/mp3';
      case 'm4a':
        return 'audio/m4a';
      case 'wav':
        return 'audio/wav';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/mov';
      default:
        return 'application/octet-stream';
    }
  }

  // Verificaciones para usuarios gratuitos
  Future<bool> canAttachFile(int fileSizeInBytes) async {
    if (_userType == UserType.premium) return true;
    
    final currentUsage = await getCurrentStorageUsage();
    return (currentUsage + fileSizeInBytes) <= _maxStorageForFreeUsers;
  }

  Future<int> getCurrentStorageUsage() async {
    try {
      final stats = await _apiService.getUserStats();
      return (stats?['totalUsedSpace'] as double?)?.toInt() ?? 0;
    } catch (e) {
      print('Error obteniendo estadísticas de uso: $e');
      return 0;
    }
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

  // Métodos adicionales de la API
  Future<List<ReflectionModel>> searchReflections(String query) async {
    try {
      return await _apiService.searchReflections(query: query);
    } catch (e) {
      print('Error buscando reflexiones: $e');
      return [];
    }
  }

  Future<List<ReflectionModel>> getReflectionsByCategory(String category) async {
    try {
      return await _apiService.getReflectionsByCategory(category: category);
    } catch (e) {
      print('Error obteniendo reflexiones por categoría: $e');
      return [];
    }
  }

  // Método público para verificar si una reflexión se puede editar
  bool canEditReflection(ReflectionModel reflection) {
    return _isValidUUID(reflection.id);
  }
}