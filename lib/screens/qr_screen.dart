import 'dart:io';

import 'package:flutter/material.dart';

import '../models/vehicle.dart';

class QRScreen extends StatelessWidget {

  final Vehicle vehicle;

  const QRScreen({
    super.key,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(vehicle.name),
      ),

      body: SafeArea(

        child: Column(

          children: [

            const SizedBox(height: 20),

            Text(
              vehicle.vehicleNumber,

              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(

              child: InteractiveViewer(

                child: Image.file(
                  File(vehicle.qrImagePath),

                  fit: BoxFit.contain,

                  errorBuilder:
                      (context, error, stackTrace) {

                    return const Center(
                      child: Text(
                        'QR image could not be loaded.',
                      ),
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),

              child: SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(

                  onPressed: () {

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            FullScreenQR(
                          vehicle: vehicle,
                        ),
                      ),
                    );
                  },

                  icon: const Icon(
                    Icons.fullscreen,
                  ),

                  label: const Text(
                    'FULL SCREEN',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenQR extends StatelessWidget {

  final Vehicle vehicle;

  const FullScreenQR({
    super.key,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text(vehicle.vehicleNumber),
      ),

      body: Center(

        child: Padding(

          padding: const EdgeInsets.all(20),

          child: Image.file(
            File(vehicle.qrImagePath),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}