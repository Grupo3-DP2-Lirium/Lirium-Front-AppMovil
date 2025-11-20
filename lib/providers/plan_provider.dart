import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/storage_service.dart';
import 'package:flutter_frontend/data/services/subscription_service.dart';
import '../data/models/subscription_response.dart';

class SubscriptionProvider extends ChangeNotifier {
  SubscriptionResponse? _subscription;
  List<String> _permissions = [];
  List<Map<String, dynamic>> _extraStorage = [];

  bool _isLoaded = false;

  SubscriptionResponse? get subscription => _subscription;
  List<String> get permissions => _permissions;
  List<Map<String, dynamic>> get extraStorage => _extraStorage;
  bool get isLoaded => _isLoaded;
  int? get maxFiles => _subscription?.maxFiles;

  /// Inicializa desde login
  void setFromLogin({
    required SubscriptionResponse? subscription,
    required List<String> permissions,
    required List<Map<String, dynamic>> extraStorage,
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
      _subscription = fresh;

      // 0. Imprimir maxFiles después de actualizar
      print(">>> maxFiles DESPUÉS de refresh: ${_subscription?.maxFiles}");

      // 2. Traer permisos del plan si existe
      if (fresh.planId != null && fresh.planId!.isNotEmpty) {
        final perms = await SubscriptionService().getPlanPermissions(fresh.planId!);
        _permissions = perms;

        // Guardamos en Storage solo si no es Free
        await StorageService.savePermissions(perms);
      } else {
        _permissions = [];
        print("Plan Free detectado, no se actualizan permisos ni Storage");
      }

    } catch (e) {
      print("ERROR EN REFRESH PLAN: $e");
    }

    _isLoaded = true;
    notifyListeners();
    print(">>> REFRESH PLAN END <<<");
  }

}
