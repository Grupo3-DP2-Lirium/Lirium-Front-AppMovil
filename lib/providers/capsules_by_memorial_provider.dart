import 'package:flutter/foundation.dart';
import 'package:flutter_frontend/data/models/capsule_model.dart';
import 'package:flutter_frontend/data/services/capsule_service.dart';

/// Provider para manejar las cápsulas asociadas a UN memorial (por memorialId)
class CapsulesByMemorialProvider extends ChangeNotifier {
  final CapsuleService _service;

  CapsulesByMemorialProvider({ CapsuleService? service }) : _service = service ?? CapsuleService();

  // Estado interno
  final List<CapsuleModel> _capsules = [];
  bool _loading = false;
  String? _error;
  bool _loaded = false;

  // Trackear qué memorial está cargado
  String? _currentMemorialId;

  List<CapsuleModel> get capsules => List.unmodifiable(_capsules);

  bool get loading => _loading;
  String? get error => _error;
  bool get loaded => _loaded;

  String? get currentMemorialId => _currentMemorialId;

  /// Cargar cápsulas para un memorial específico
  Future<void> loadCapsules({ required String memorialId, bool force = false }) async {
    // Si el memorial cambió, limpiar
    if (_currentMemorialId != null && _currentMemorialId != memorialId) {
      if (kDebugMode) print('Memorial cambió de $_currentMemorialId a $memorialId - limpiando...');
      _clearState();
    }

    // Si ya cargó el mismo memorial y no se fuerza, no hacer nada
    if (_currentMemorialId == memorialId && _loaded && !force) {
      if (kDebugMode) print('Cápsulas del memorial $memorialId ya cargadas - skipping');
      return;
    }

    _currentMemorialId = memorialId;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      if (kDebugMode) print('Cargando cápsulas para memorial: $memorialId');

      final capsulesFromApi = await _service.getCapsulesByMemorial(memorialId);
      _capsules.clear();
      _capsules.addAll(capsulesFromApi);

      // Imprimir cada cápsula
      if (kDebugMode) {
        for (var c in _capsules) {
          print('Cápsula recibida: id=${c.idCapsule}, title=${c.title}, videoUrl=${c.videoUrl}');
        }
      }

      _loaded = true;

      if (kDebugMode) print('Recibidas ${_capsules.length} cápsulas');
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('Error cargando cápsulas: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Forzar recarga
  Future<void> reload({ required String memorialId }) async {
    await loadCapsules(memorialId: memorialId, force: true);
  }

  /// Agregar cápsula localmente
  void addCapsule(CapsuleModel capsule) {
    if (_capsules.any((c) => c.idCapsule == capsule.idCapsule)) return;
    _capsules.insert(0, capsule);
    notifyListeners();
  }

  /// Actualizar cápsula localmente
  void updateCapsule(String id, CapsuleModel updated) {
    final idx = _capsules.indexWhere((c) => c.idCapsule == id);
    if (idx != -1) {
      _capsules[idx] = updated;
      notifyListeners();
    }
  }

  /// Eliminar cápsula localmente
  void removeCapsule(String id) {
    _capsules.removeWhere((c) => c.idCapsule == id);
    notifyListeners();
  }

  /// Limpiar estado
  void clear() {
    _clearState();
    _currentMemorialId = null;
    notifyListeners();
  }

  void _clearState() {
    _capsules.clear();
    _loading = false;
    _error = null;
    _loaded = false;
  }
}
