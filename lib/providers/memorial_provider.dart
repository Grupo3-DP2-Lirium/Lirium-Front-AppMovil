import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/memorial_service.dart';
import 'package:flutter_frontend/domain/entities/memorial.dart';

class MemorialProvider extends ChangeNotifier {
  final _service = MemorialService();

  List<Memorial> _misMemoriales = [];
  List<Memorial> _colaborativos = [];

  bool _cargandoMis = false;
  bool _cargandoColab = false;
  String? _errorMis;
  String? _errorColab;

  List<Memorial> get misMemoriales => _misMemoriales;
  List<Memorial> get colaborativos => _colaborativos;
  bool get cargandoMis => _cargandoMis;
  bool get cargandoColab => _cargandoColab;
  String? get errorMis => _errorMis;
  String? get errorColab => _errorColab;

  bool _loadedMis = false;
  bool _loadedColab = false;
  bool get loadedMis => _loadedMis;
  bool get loadedColab => _loadedColab;

  int _pageMis = 0;
  bool _hasMoreMis = true;

  Future<void> cargarMisMemoriales({bool force = false}) async {

    if (force) {
      _misMemoriales = [];
      _pageMis = 0;
      _hasMoreMis = true;
    }

    if (!_hasMoreMis) return;

    _cargandoMis = true;
    notifyListeners();

    try {
      final result = await _service.getMemorials(page: _pageMis, size: 6);

      _misMemoriales.addAll(result.items);

      _hasMoreMis = (result.page + 1) < result.totalPages;

      _pageMis++;

    } finally {
      _cargandoMis = false;
      notifyListeners();
    }
  }

  Future<void> cargarColaborativos({bool force = false}) async {
    print('📋 cargarColaborativos - force: $force, cargando: $_cargandoColab, loaded: $_loadedColab');

    if (force) {
      _loadedColab = false;
    }

    if (_cargandoColab || (_loadedColab && !force)) {
      print('⏭️ Skipped - ya cargado o cargando');
      return;
    }

    _cargandoColab = true;
    _errorColab = null;
    notifyListeners();

    try {
      print('📡 Llamando getMyCollaborations()...');
      
      // ✅ Usar el nuevo endpoint específico
      _colaborativos = await _service.getMyCollaborations();
      _loadedColab = true;
      
      print('✅ Colaborativos cargados: ${_colaborativos.length}');
    } catch (e) {
      print('❌ Error cargando colaborativos: $e');
      _errorColab = e.toString();
      _colaborativos = [];
    } finally {
      _cargandoColab = false;
      notifyListeners();
    }
  }
  
  Future<void> recargarTodo() async {
    _loadedMis = false; _loadedColab = false;
    await Future.wait([
      cargarMisMemoriales(force: true),
      cargarColaborativos(force: true),
    ]);
  }

  /// Agrega un nuevo memorial al inicio de la lista de misMemoriales
  void agregarMemorial(Memorial memorial) {
    _misMemoriales.insert(0, memorial);
    notifyListeners();
  }

  void eliminarMemorial(String id) {
    _misMemoriales.removeWhere((m) => m.idMemorial == id);
    _colaborativos.removeWhere((m) => m.idMemorial == id);
    notifyListeners();
  }
  
  void limpiarTodo() {
    print('🧹 Limpiando MemorialProvider...');
    
    _misMemoriales = [];
    _colaborativos = [];
    
    _cargandoMis = false;
    _cargandoColab = false;
    
    _errorMis = null;
    _errorColab = null;
    
    _loadedMis = false;
    _loadedColab = false;

    notifyListeners();
    
    print('✅ MemorialProvider limpiado');
  }
}

