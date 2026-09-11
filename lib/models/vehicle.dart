class Vehicle {
  final String id;
  final String name;
  final String vehicleNumber;
  final String qrImagePath;

  Vehicle({
    required this.id,
    required this.name,
    required this.vehicleNumber,
    required this.qrImagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'vehicleNumber': vehicleNumber,
      'qrImagePath': qrImagePath,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      name: map['name'],
      vehicleNumber: map['vehicleNumber'],
      qrImagePath: map['qrImagePath'],
    );
  }
}
