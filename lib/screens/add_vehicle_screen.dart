import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/vehicle.dart';
import '../services/vehicle_storage.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() =>
      _AddVehicleScreenState();
}

class _AddVehicleScreenState
    extends State<AddVehicleScreen> {

  final nameController = TextEditingController();
  final numberController = TextEditingController();

  File? selectedImage;

  final ImagePicker picker = ImagePicker();

  Future<void> selectQRImage() async {

    final XFile? image =
        await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) {
      return;
    }

    setState(() {
      selectedImage = File(image.path);
    });
  }

  Future<String> saveImageLocally(File image) async {

    final directory =
        await getApplicationDocumentsDirectory();

    final fileName =
        'qr_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final newPath =
        '${directory.path}/$fileName';

    final newImage =
        await image.copy(newPath);

    return newImage.path;
  }

  Future<void> saveVehicle() async {

    if (nameController.text.isEmpty ||
        numberController.text.isEmpty ||
        selectedImage == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all fields and select the QR image.',
          ),
        ),
      );

      return;
    }

    final localImagePath =
        await saveImageLocally(selectedImage!);

    final vehicle = Vehicle(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),

      name: nameController.text.trim(),

      vehicleNumber:
          numberController.text.trim(),

      qrImagePath: localImagePath,
    );

    await VehicleStorage.saveVehicle(vehicle);

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Add Vehicle'),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [

            TextField(
              controller: nameController,

              decoration: const InputDecoration(
                labelText: 'Vehicle Name',
                hintText: 'Example: My Car',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: numberController,

              decoration: const InputDecoration(
                labelText: 'Vehicle Number',
                hintText: 'Example: WP CAA 1234',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            if (selectedImage != null)

              Container(
                height: 250,

                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),

                child: Image.file(
                  selectedImage!,
                  fit: BoxFit.contain,
                ),
              )

            else

              Container(
                height: 250,

                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),

                child: const Center(
                  child: Text(
                    'No QR image selected',
                  ),
                ),
              ),

            const SizedBox(height: 20),

            OutlinedButton.icon(

              onPressed: selectQRImage,

              icon: const Icon(
                Icons.photo_library,
              ),

              label: const Text(
                'SELECT QR FROM GALLERY',
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton(

              onPressed: saveVehicle,

              child: const Padding(
                padding: EdgeInsets.all(15),

                child: Text(
                  'SAVE VEHICLE',
                  style: TextStyle(
                    fontSize: 16,
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