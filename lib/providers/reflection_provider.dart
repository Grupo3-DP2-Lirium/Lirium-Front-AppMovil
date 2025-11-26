import 'package:flutter/material.dart';
import '../data/models/reflection_model.dart';
import '../data/services/reflection_service.dart';

class ReflectionProvider extends ChangeNotifier {
  final ReflectionService _service = ReflectionService();

  List<ReflectionModel> _reflections = [];
  List<ReflectionModel> get reflections => _reflections;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasLoadedOnce = false;

  Future<void> loadReflections() async {
    // Si ya se cargó antes → no volver a cargar
    if (_hasLoadedOnce) return;

    _isLoading = true;
    notifyListeners();

    final data = await _service.getAllReflections();
    _reflections = data;
    _hasLoadedOnce = true;

    _isLoading = false;
    notifyListeners();
  }

  /// Refrescar manualmente (pull to refresh)
  Future<void> refreshReflections() async {
    _isLoading = true;
    notifyListeners();

    final data = await _service.getAllReflections();
    _reflections = data;

    _isLoading = false;
    notifyListeners();
  }

  /// Guardar (crear o actualizar)
  Future<ReflectionModel?> saveReflection(ReflectionModel reflection) async {
    final result = await _service.saveReflection(reflection);
    if (result == null) return null;

    // Si la reflexión ya existe -> reemplazar
    final index = _reflections.indexWhere((r) => r.id == result.id);
    if (index != -1) {
      _reflections[index] = result;
    } else {
      // Si es nueva -> agregar
      _reflections.insert(0, result);
    }

    notifyListeners();
    return result;
  }

  /// Eliminar reflexión
  Future<bool> deleteReflection(String id) async {
    final ok = await _service.deleteReflection(id);
    if (!ok) return false;

    _reflections.removeWhere((r) => r.id == id);
    notifyListeners();
    return true;
  }

  /// Obtener por ID (desde el provider, más rápido)
  ReflectionModel? getById(String id) {
    try {
      return _reflections.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Buscar reflexiones (no modifica la lista principal)
  Future<List<ReflectionModel>> search(String query) async {
    if (query.isEmpty) return [];
    return await _service.searchReflections(query);
  }
}