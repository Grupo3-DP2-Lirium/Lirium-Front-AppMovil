import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/capsule_model.dart';
import 'package:flutter_frontend/data/models/capsule_request.dart';
import 'package:flutter_frontend/data/models/capsule_filter_model.dart';
import 'package:flutter_frontend/data/services/capsule_service.dart';

class CapsuleProvider extends ChangeNotifier {
  final _service = CapsuleService();

  List<CapsuleModel> _capsules = [];
  List<CapsuleFilterModel> _filters = [];

  bool _loading = false;
  bool _loadingFilters = false;
  String? _error;

  Timer? _pollingTimer;
  final Set<String> _processingCapsules = {};

  List<CapsuleModel> get capsules => _capsules;
  List<CapsuleFilterModel> get filters => _filters;
  bool get loading => _loading;
  bool get loadingFilters => _loadingFilters;
  String? get error => _error;
  bool get hasProcessingCapsules => _processingCapsules.isNotEmpty;

  // Filtrar por estado
  List<CapsuleModel> get draftCapsules =>
      _capsules.where((c) => c.isDraft ||
          c.isCompleted ||
          c.isProcessing ||
          c.isFailed ||
          c.isCancelled).toList();

  List<CapsuleModel> get publishedCapsules =>
      _capsules.where((c) => c.isPublished).toList();

  /// Cargar todas las cápsulas del usuario
  Future<void> loadMyCapsules({bool force = false}) async {
    if (_loading && !force) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _capsules = await _service.getMyCapsules();
      _checkProcessingCapsules();
    } catch (e) {
      _error = e.toString();
      print('ERROR loading capsules: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Crear una nueva cápsula (DRAFT)
  Future<CapsuleModel?> createCapsule(CapsuleRequestModel request) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final capsule = await _service.createCapsule(request);
      print('DEBUG: Capsule created in DRAFT: ${capsule.idCapsule}');

      _capsules.insert(0, capsule);
      notifyListeners();
      return capsule;
    } catch (e) {
      _error = e.toString();
      print('ERROR creating capsule: $e');
      notifyListeners();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Iniciar generación de la cápsula
  Future<CapsuleModel?> generateCapsule(String capsuleId) async {
    try {
      final capsule = await _service.generateCapsule(capsuleId);
      print('DEBUG: Generation started: ${capsule.idCapsule}');

      final index = _capsules.indexWhere((c) => c.idCapsule == capsuleId);
      if (index != -1) {
        _capsules[index] = capsule;

        if (capsule.isProcessing) {
          _processingCapsules.add(capsuleId);
          _startPolling();
        }

        notifyListeners();
      }

      return capsule;
    } catch (e) {
      String message;

      if (e is DioException && e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] ??
              responseData['error'] ??
              e.message ??
              'Error desconocido';
        } else {
          message = e.message ?? 'Error desconocido';
        }
      } else {
        // Para Exception lanzadas desde el servicio (Exception('mi mensaje'))
        message = e.toString();
        // Quitar el prefijo "Exception: " si existe
        if (message.startsWith('Exception: ')) {
          message = message.replaceFirst('Exception: ', '');
        }
      }

      _error = message;
      print('ERROR generating capsule: $_error');
      notifyListeners();
      return null;
    }
  }

  /// Publicar cápsula
  Future<CapsuleModel?> publishCapsule(String capsuleId) async {
    try {
      final capsule = await _service.publishCapsule(capsuleId);
      print('DEBUG: Capsule published: ${capsule.idCapsule}');

      final index = _capsules.indexWhere((c) => c.idCapsule == capsuleId);
      if (index != -1) {
        _capsules[index] = capsule;
        notifyListeners();
      }

      return capsule;
    } catch (e) {
      _error = e.toString();
      print('ERROR publishing capsule: $e');
      notifyListeners();
      return null;
    }
  }

  /// Actualizar cápsula
  Future<CapsuleModel?> updateCapsule(
      String capsuleId,
      CapsuleRequestModel request,
      ) async {
    try {
      final capsule = await _service.updateCapsule(capsuleId, request);
      print('DEBUG: Capsule updated: ${capsule.idCapsule}');

      final index = _capsules.indexWhere((c) => c.idCapsule == capsuleId);
      if (index != -1) {
        _capsules[index] = capsule;
        notifyListeners();
      }

      return capsule;
    } catch (e) {
      _error = e.toString();
      print('ERROR updating capsule: $e');
      notifyListeners();
      return null;
    }
  }

  /// Actualizar estado de una cápsula específica
  Future<void> refreshCapsuleStatus(String capsuleId) async {
    try {
      final updated = await _service.getCapsuleStatus(capsuleId);

      final index = _capsules.indexWhere(
            (c) => c.idCapsule == capsuleId,
      );

      if (index != -1) {
        final old = _capsules[index].progress;

        _capsules[index] = updated;

        print('Progress ${updated.idCapsule}: $old -> ${updated.progress} (status: ${updated.status})');

        if (!updated.isProcessing) {
          _processingCapsules.remove(capsuleId);
          if (_processingCapsules.isEmpty) {
            _stopPolling();
          }
        }

        notifyListeners();
      }
    } catch (e) {
      print('ERROR refreshing capsule status: $e');
    }
  }

  /// Cancelar una cápsula
  Future<bool> cancelCapsule(String capsuleId) async {
    try {
      await _service.cancelCapsule(capsuleId);
      _processingCapsules.remove(capsuleId);
      await refreshCapsuleStatus(capsuleId);
      return true;
    } catch (e) {
      _error = e.toString();
      print('ERROR cancelling capsule: $e');
      notifyListeners();
      return false;
    }
  }

  /// Eliminar una cápsula
  Future<bool> deleteCapsule(String capsuleId) async {
    try {
      await _service.deleteCapsule(capsuleId);
      _capsules.removeWhere((c) => c.idCapsule == capsuleId);
      _processingCapsules.remove(capsuleId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('ERROR deleting capsule: $e');
      notifyListeners();
      return false;
    }
  }

  /// Cargar catálogo de filtros
  Future<void> loadFilters() async {
    if (_filters.isNotEmpty) return;

    _loadingFilters = true;
    notifyListeners();

    try {
      _filters = await _service.getFilters();
    } catch (e) {
      print('ERROR loading filters: $e');
    } finally {
      _loadingFilters = false;
      notifyListeners();
    }
  }

  void _checkProcessingCapsules() {
    _processingCapsules.clear();

    for (var capsule in _capsules) {
      if (capsule.isProcessing) {
        _processingCapsules.add(capsule.idCapsule);
      }
    }

    if (_processingCapsules.isNotEmpty) {
      _startPolling();
    } else {
      _stopPolling();
    }
  }

  void _startPolling() {
    if (_pollingTimer != null && _pollingTimer!.isActive) return;

    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      for (var capsuleId in _processingCapsules.toList()) {
        await refreshCapsuleStatus(capsuleId);
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}