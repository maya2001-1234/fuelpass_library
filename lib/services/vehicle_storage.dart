import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/vehicle.dart';

class VehicleStorage {
  static const String boxName = 'vehicles';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  static Box get _box => Hive.box(boxName);

  static Future<void> saveVehicle(Vehicle vehicle) async {
    await _box.put(vehicle.id, jsonEncode(vehicle.toMap()));
  }

  static List<Vehicle> getVehicles() {
    return _box.values.map((item) {
      final map = jsonDecode(item);
      return Vehicle.fromMap(Map<String, dynamic>.from(map));
    }).toList();
  }

  static Future<void> deleteVehicle(String id) async {
    await _box.delete(id);
  }
}
