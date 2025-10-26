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

  Future<void> cargarMisMemoriales({bool force = false}) async {
    print('DEBUG: cargarMisMemoriales called - force: $force, _cargandoMis: $_cargandoMis, _loadedMis: $_loadedMis');
    
    // Si force=true, resetear el flag para forzar recarga
    if (force) {
      _loadedMis = false;
      print('DEBUG: Force reload - resetting _loadedMis');
    }
    
    if (_cargandoMis || (_loadedMis && !force)) {
      print('DEBUG: cargarMisMemoriales skipped - already loading or loaded');
      return;
    }
    print('DEBUG: Starting to load mis memoriales...');
    _cargandoMis = true; _errorMis = null; notifyListeners();
    try {
      _misMemoriales = await _service.getMemorials();
      _loadedMis = true;
      print('DEBUG: Successfully loaded ${_misMemoriales.length} mis memoriales');
    } catch (e) {
      _errorMis = e.toString();
      print('ERROR loading mis memoriales: $e');
    } finally {
      _cargandoMis = false; notifyListeners();
    }
  }

  Future<void> cargarColaborativos({bool force = false}) async {
    print('DEBUG: cargarColaborativos called - force: $force, _cargandoColab: $_cargandoColab, _loadedColab: $_loadedColab');
    
    // Si force=true, resetear el flag para forzar recarga
    if (force) {
      _loadedColab = false;
      print('DEBUG: Force reload - resetting _loadedColab');
    }
    
    if (_cargandoColab || (_loadedColab && !force)) {
      print('DEBUG: cargarColaborativos skipped - already loading or loaded');
      return;
    }
    print('DEBUG: Starting to load colaborativos...');
    _cargandoColab = true; _errorColab = null; notifyListeners();
    try {
      _colaborativos = await _service.getCollaborativeMemorials();
      _loadedColab = true;
      print('DEBUG: Successfully loaded ${_colaborativos.length} colaborativos');
    } catch (e) {
      _errorColab = e.toString();
      print('ERROR loading colaborativos: $e');
    } finally {
      _cargandoColab = false; notifyListeners();
    }
  }

  Future<void> recargarTodo() async {
    _loadedMis = false; _loadedColab = false;
    await Future.wait([
      cargarMisMemoriales(force: true),
      cargarColaborativos(force: true),
    ]);
  }
}

