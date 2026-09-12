import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/vehicle_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await VehicleStorage.init();

  runApp(const FuelMateApp());
}

class FuelMateApp extends StatelessWidget {
  const FuelMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FuelPass Library',

      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),

      home: const HomeScreen(),
    );
  }
}
