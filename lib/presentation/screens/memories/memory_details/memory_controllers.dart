import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LocationController extends TextEditingController {
  double? latitude;
  double? longitude;

  LocationController({String? text, this.latitude, this.longitude}) : super(text: text);

  void setLocation({
    required String address,
    required double lat,
    required double lon,
  }) {
    this.text = address;
    latitude = lat;
    longitude = lon;
  }

  Future<void> fetchAddressFromLatLon() async {
    if (latitude == null || longitude == null) return;

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json&addressdetails=1',
      );
      final response = await http.get(url, headers: {'User-Agent': 'FlutterApp'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] ?? {};
        String cityName = address['city'] ??
            address['town'] ??
            address['village'] ??
            address['hamlet'] ??
            address['municipality'] ??
            address['county'] ??
            address['state'] ??
            '';

        if (cityName.isNotEmpty) {
          text = cityName;
        }
      }
    } catch (e) {
      debugPrint('Error al obtener nombre del lugar: $e');
    }
  }

  void clear() {
    text = '';
    latitude = null;
    longitude = null;
  }

  bool get isValid => latitude != null && longitude != null;
}

class DateController {
  DateTime? date;

  DateController({this.date});

  void setDate(DateTime newDate) {
    date = newDate;
  }

  void clear() {
    date = null;
  }

  String get formattedDate {
    if (date == null) return "";
    return "${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}";
  }

  bool get isValid => date != null;
}
