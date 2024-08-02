import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String name;
  final double capacity;
  final String specFeatures;
  final String vLabel;
  List<DocumentReference>? ownRide;

  Vehicle(
      {required this.vLabel,
      required this.name,
      required this.capacity,
      required this.specFeatures,
      this.ownRide});

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
        vLabel: map['vLabel'],
        name: map['name'],
        capacity: map['capacity'],
        specFeatures: map['specFeatures'],
        ownRide: List<DocumentReference>.from(map['ownRide'] ?? []));
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'capacity': capacity,
      'specFeatures': specFeatures,
      'vLabel': vLabel,
      'ownRide': ownRide,
    };
  }

  static final _firestore = FirebaseFirestore.instance;

  static Future<void> addVehicle(Vehicle newVehicle) async {
    try {
      await _firestore
          .collection('Vehicle')
          .doc(newVehicle.vLabel)
          .set(newVehicle.toMap());
    } catch (e) {
      print("ERROR ADDVEHICLE: $e");
    }
  }

  static Future<Vehicle?> fetchVehicle(DocumentReference vSnap) async {
    try {
      final doc = await vSnap.get();
      final vec = Vehicle.fromMap(doc.data() as Map<String, dynamic>);
      return vec;
    } catch (e) {
      print('ERROR FETCHVEHICLE: $e');
      return null;
    }
  }

  static Future<void> updateVehicle(String label, Vehicle updateVeh) async {
    try {
      await _firestore.collection('Vehicle').doc(label).update({
        'name': updateVeh.name,
        'capacity': updateVeh.capacity,
        'specFeatures': updateVeh.specFeatures
      });
    } catch (e) {
      print('ERROR UPDATEVEHICLE: $e');
    }
  }

  static Future<void> addRide(String labelRide, String labelVehicle) async {
    final snapRide = _firestore.collection('Ride').doc(labelRide);
    await _firestore.collection('Vehicle').doc(labelVehicle).update({
      'ownRide': FieldValue.arrayUnion([snapRide])
    });
  }
}
