import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/documentary_model.dart';
import 'package:flutter_frontend/data/models/documentary_request.dart';
import 'package:flutter_frontend/data/models/music_track_model.dart';
import 'package:flutter_frontend/data/services/documentary_service.dart';

class DocumentaryProvider extends ChangeNotifier {
  final _service = DocumentaryService();

  List<DocumentaryModel> _documentaries = [];
  List<MusicTrackModel> _musicCatalog = [];

  bool _loading = false;
  bool _loadingMusic = false;
  String? _error;

  Timer? _pollingTimer;
  final Set<String> _processingDocumentaries = {};

  List<DocumentaryModel> get documentaries => _documentaries;
  List<MusicTrackModel> get musicCatalog => _musicCatalog;
  bool get loading => _loading;
  bool get loadingMusic => _loadingMusic;
  String? get error => _error;
  bool get hasProcessingDocumentaries => _processingDocumentaries.isNotEmpty;

  /// Cargar todos los documentales del usuario
  Future<void> loadMyDocumentaries({bool force = false}) async {
    print('DEBUG: loadMyDocumentaries called - force: $force');

    if (_loading && !force) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _documentaries = await _service.getMyDocumentaries();
      print('DEBUG: Loaded ${_documentaries.length} documentaries');

      // Iniciar polling si hay documentales procesando
      _checkProcessingDocumentaries();
    } catch (e) {
      _error = e.toString();
      print('ERROR loading documentaries: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Cargar documentales de un memorial específico
  Future<void> loadDocumentariesByMemorial(String memorialId) async {
    print('DEBUG: loadDocumentariesByMemorial($memorialId)');

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _documentaries = await _service.getDocumentariesByMemorial(memorialId);
      print('DEBUG: Loaded ${_documentaries.length} documentaries for memorial');

      _checkProcessingDocumentaries();
    } catch (e) {
      _error = e.toString();
      print('ERROR loading documentaries by memorial: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Crear un nuevo documental
  Future<DocumentaryModel?> createDocumentary(
      DocumentaryRequestModel request,
      ) async {
    print('DEBUG: createDocumentary called');

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final documentary = await _service.createDocumentary(request);
      print('DEBUG: Documentary created: ${documentary.idDocumentary}');

      // Agregar al inicio de la lista
      _documentaries.insert(0, documentary);

      // Iniciar polling si está procesando
      if (documentary.isProcessing) {
        _processingDocumentaries.add(documentary.idDocumentary);
        _startPolling();
      }

      notifyListeners();
      return documentary;
    } catch (e) {
      _error = e.toString();
      print('ERROR creating documentary: $e');
      notifyListeners();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Actualizar estado de un documental específico
  Future<void> refreshDocumentaryStatus(String documentaryId) async {
    try {
      final updated = await _service.getDocumentaryStatus(documentaryId);

      final index = _documentaries.indexWhere(
            (d) => d.idDocumentary == documentaryId,
      );

      if (index != -1) {
        _documentaries[index] = updated;

        // Si completó o falló, quitar del polling
        if (!updated.isProcessing) {
          _processingDocumentaries.remove(documentaryId);

          // Si no hay más procesando, detener polling
          if (_processingDocumentaries.isEmpty) {
            _stopPolling();
          }
        }

        notifyListeners();
      }
    } catch (e) {
      print('ERROR refreshing documentary status: $e');
    }
  }

  /// Cancelar un documental
  Future<bool> cancelDocumentary(String documentaryId) async {
    try {
      await _service.cancelDocumentary(documentaryId);

      _processingDocumentaries.remove(documentaryId);
      await refreshDocumentaryStatus(documentaryId);

      return true;
    } catch (e) {
      _error = e.toString();
      print('ERROR cancelling documentary: $e');
      notifyListeners();
      return false;
    }
  }

  /// Eliminar un documental
  Future<bool> deleteDocumentary(String documentaryId) async {
    try {
      await _service.deleteDocumentary(documentaryId);

      _documentaries.removeWhere((d) => d.idDocumentary == documentaryId);
      _processingDocumentaries.remove(documentaryId);

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('ERROR deleting documentary: $e');
      notifyListeners();
      return false;
    }
  }

  /// Cargar catálogo de música
  Future<void> loadMusicCatalog() async {
    if (_musicCatalog.isNotEmpty) return; // Solo cargar una vez

    _loadingMusic = true;
    notifyListeners();

    try {
      _musicCatalog = await _service.getMusicCatalog();
      print('DEBUG: Loaded ${_musicCatalog.length} music tracks');
    } catch (e) {
      print('ERROR loading music catalog: $e');
    } finally {
      _loadingMusic = false;
      notifyListeners();
    }
  }

  /// Verificar si hay documentales procesando
  void _checkProcessingDocumentaries() {
    _processingDocumentaries.clear();

    for (var doc in _documentaries) {
      if (doc.isProcessing) {
        _processingDocumentaries.add(doc.idDocumentary);
      }
    }

    if (_processingDocumentaries.isNotEmpty) {
      _startPolling();
    } else {
      _stopPolling();
    }
  }

  /// Iniciar polling de documentales en proceso
  void _startPolling() {
    if (_pollingTimer != null && _pollingTimer!.isActive) return;

    print('DEBUG: Starting polling for ${_processingDocumentaries.length} documentaries');

    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      print('DEBUG: Polling tick - ${_processingDocumentaries.length} processing');

      for (var documentaryId in _processingDocumentaries.toList()) {
        await refreshDocumentaryStatus(documentaryId);
      }
    });
  }

  /// Detener polling
  void _stopPolling() {
    print('DEBUG: Stopping polling');
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}