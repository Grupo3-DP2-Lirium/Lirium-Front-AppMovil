import 'package:flutter/material.dart';

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

  bool get isValid => latitude != null && longitude != null;
}

class DateController {
  DateTime? date;

  DateController({this.date});

  void setDate(DateTime newDate) {
    date = newDate;
  }

  String get formattedDate {
    if (date == null) return "";
    return "${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}";
  }

  bool get isValid => date != null;
}
