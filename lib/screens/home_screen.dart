import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../services/vehicle_storage.dart';
import 'add_vehicle_screen.dart';
import 'qr_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Vehicle> vehicles = [];

  @override
  void initState() {
    super.initState();
    loadVehicles();
  }

  void loadVehicles() {
    setState(() {
      vehicles = VehicleStorage.getVehicles();
    });
  }

  Future<void> deleteVehicle(String id) async {
    await VehicleStorage.deleteVehicle(id);
    loadVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FuelMate LK',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: vehicles.isEmpty
          ? const Center(
              child: Text(
                'No vehicles added yet.\n\nTap + to add your vehicle.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),

              itemCount: vehicles.length,

              itemBuilder: (context, index) {
                final vehicle = vehicles[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          vehicle.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          vehicle.vehicleNumber,
                          style: const TextStyle(fontSize: 16),
                        ),

                        const SizedBox(height: 15),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          QRScreen(vehicle: vehicle),
                                    ),
                                  );
                                },

                                icon: const Icon(Icons.qr_code),

                                label: const Text('VIEW QR'),
                              ),
                            ),

                            const SizedBox(width: 10),

                            IconButton(
                              onPressed: () {
                                deleteVehicle(vehicle.id);
                              },

                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
          );

          loadVehicles();
        },

        child: const Icon(Icons.add),
      ),
    );
  }
}
