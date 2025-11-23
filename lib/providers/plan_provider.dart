import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/extra_storage_response.dart';
import 'package:flutter_frontend/data/services/storage_service.dart';
import 'package:flutter_frontend/data/services/subscription_service.dart';
import '../data/models/subscription_response.dart';

class SubscriptionProvider extends ChangeNotifier {
  SubscriptionResponse? _subscription;
  List<String> _permissions = [];
  List<ExtraStorageResponse> _extraStorage = [];

  bool _isLoaded = false;

  Future<void> loadCurrentSubscription() async {
    notifyListeners();
    _isLoaded = true;
  }

  SubscriptionResponse? get subscription => _subscription;
  List<String> get permissions => _permissions;
  List<ExtraStorageResponse> get extraStorage => _extraStorage;
  bool get isLoaded => _isLoaded;
  int? get maxFiles => _subscription?.maxFiles;
  String get planName => _subscription?.planName ?? 'Free';

  /// Inicializa desde login
  void setFromLogin({
    required SubscriptionResponse? subscription,
    required List<String> permissions,
    required List<ExtraStorageResponse> extraStorage,
  }) {
    _subscription = subscription;
    _permissions = permissions;
    _extraStorage = extraStorage;
    _isLoaded = true;
    notifyListeners();
    //print(">>> PROVIDER SET FROM LOGIN <<<");

    //print("Subscription RECIBIDA en parámetro: $subscription");
    //print("Plan Name: ${subscription?.planName}");
    //print("Permissions RECIBIDOS: $permissions");
    //print("Extra Storage RECIBIDO: $extraStorage");

  }

  /// Cargar desde Storage si quieres persistencia
  Future<void> loadFromStorage() async {
    _isLoaded = false;

    final subscriptionJson = await StorageService.getFullSubscriptionJson();
    final permissions = await StorageService.getPermissions() ?? [];
    final extra = await StorageService.getExtraStorageSubscriptions() ?? [];

    if (subscriptionJson != null) {
      _subscription = SubscriptionResponse.fromJson(subscriptionJson);
    }

    _permissions = permissions;
    _extraStorage = extra;

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> refreshPlan() async {
    print(">>> REFRESH PLAN START <<<");
    _isLoaded = false;
    notifyListeners();

    try {
      // 0. Imprimir maxFiles antes de actualizar
      print(">>> maxFiles ANTES de refresh: ${_subscription?.maxFiles}");

      // 1. Traer la suscripción fresca desde backend
      final fresh = await SubscriptionService().getCurrentSubscription();
      print(">>> REFRESH: Backend devolvió plan: ${fresh.planName}");

      // 2. Traer permisos del plan si existe
      if (fresh.planId != null && fresh.planId!.isNotEmpty) {
        final perms = await SubscriptionService().getPlanPermissions(fresh.planId!);
        _permissions = perms;
        _subscription = fresh;
        _extraStorage = fresh.extraStorage ?? [];
        // Guardamos en Storage solo si no es Free
        await StorageService.savePermissions(perms);
      } else {
        // Si es free no tiene id
        final perms = await SubscriptionService().getPlanPermissions(fresh.planId!);
        _permissions = perms;
        _subscription = fresh;
        _extraStorage = fresh.extraStorage ?? [];
        // Guardamos en Storage solo si no es Free
        await StorageService.savePermissions(perms);
        print("Plan Free detectado");
      }

      // 0. Imprimir maxFiles después de actualizar
      print(">>> maxFiles DESPUÉS de refresh: ${_subscription?.maxFiles}");

    } catch (e) {
      print("ERROR EN REFRESH PLAN: $e");
    }

    _isLoaded = true;
    notifyListeners();
    print(">>> REFRESH PLAN END <<<");
  }

}
