import '../data/services/storage_service.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? token;
  String? name;
  String? photoUrl;
  String? email;

  Future<void> loadUser() async {
    token = await StorageService.getToken();
    name = await StorageService.getName();
    photoUrl = await StorageService.getProfilePhotoUrl();
    email = await StorageService.getEmail();
    notifyListeners();
  }

  void logout() async {
    token = null;
    name = null;
    photoUrl = null;
    email = null;

    await StorageService.clearAll();
    notifyListeners();
  }
}
