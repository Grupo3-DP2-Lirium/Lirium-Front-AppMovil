import 'package:flutter/material.dart';
import '../data/models/memorial_response.dart';
import '../data/services/http_service.dart';

class MemorialProvider extends ChangeNotifier {
  final _api = HttpService();

  List<MemorialResponseModel> _misMemoriales = [];
  List<MemorialResponseModel> _colaborativos = [];

  bool _cargandoMis = false;
  bool _cargandoColab = false;
  String? _errorMis;
  String? _errorColab;

  List<MemorialResponseModel> get misMemoriales => _misMemoriales;
  List<MemorialResponseModel> get colaborativos => _colaborativos;
  bool get cargandoMis => _cargandoMis;
  bool get cargandoColab => _cargandoColab;
  String? get errorMis => _errorMis;
  String? get errorColab => _errorColab;

  bool _loadedMis = false;
  bool _loadedColab = false;
  bool get loadedMis => _loadedMis;
  bool get loadedColab => _loadedColab;

  Future<void> cargarMisMemoriales({bool force = false}) async {
    if (_cargandoMis || (_loadedMis && !force)) return;
    _cargandoMis = true; _errorMis = null; notifyListeners();
    try {
      _misMemoriales = await _api.getMyMemorials();
      _loadedMis = true;
    } catch (e) {
      _errorMis = e.toString();
    } finally {
      _cargandoMis = false; notifyListeners();
    }
  }

  Future<void> cargarColaborativos({bool force = false}) async {
    if (_cargandoColab || (_loadedColab && !force)) return;
    _cargandoColab = true; _errorColab = null; notifyListeners();
    try {
      _colaborativos = await _api.getCollaborativeMemorials();
      _loadedColab = true;
    } catch (e) {
      _errorColab = e.toString();
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

