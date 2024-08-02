import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d1_wsf24_driver/Modal/vehicle_repo.dart';

class Ride {
  final DateTime date;
  final String origin;
  final String destination;
  final String fare;
  final List<String>? rider;
  final String label;

  Ride(
      {required this.date,
      required this.origin,
      required this.destination,
      required this.fare,
      this.rider,
      required this.label});

  factory Ride.fromMap(Map<String, dynamic> map) {
    return Ride(
        date: DateTime.parse(map['date']),
        origin: map['origin'],
        destination: map['destination'],
        fare: map['fare'],
        rider: List<String>.from(map['rider'] ?? []),
        label: map['label']);
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toString(),
      'origin': origin,
      'destination': destination,
      'fare': fare,
      'rider': rider,
      'label': label,
    };
  }

  static final _firebase = FirebaseFirestore.instance;

  static Future<List<Ride>> getRide(Vehicle currVeh) async {
    try {
      List<Ride> rideList = [];

      for (var ride in currVeh.ownRide!) {
        final snapshot = await ride.get();

        rideList.add(Ride.fromMap(snapshot.data() as Map<String, dynamic>));
      }
      return rideList;
    } catch (e) {
      print('ERROR GETRIDE: $e');
      return [];
    }
  }

  static Future<void> addRide(Ride newRide, bool isEdit, String? label) async {
    try {
      if (isEdit) {
        await _firebase.collection('Ride').doc(label).update({
          'date': newRide.date.toString(),
          'origin': newRide.origin,
          'destination': newRide.destination,
          'fare': newRide.fare,
          'rider': newRide.rider,
        });
      } else {
        await _firebase
            .collection('Ride')
            .doc(newRide.label)
            .set(newRide.toMap());
      }
    } catch (e) {
      print('ERROR ADDRIDE: $e');
    }
  }

  static Future<void> deleteRide(String rideLabel, String vehicleLabel) async {
    await _firebase.collection('Ride').doc(rideLabel).delete();

    await _firebase.collection('Vehicle').doc(vehicleLabel).update({
      'ownRide':
          FieldValue.arrayRemove([_firebase.collection('Ride').doc(rideLabel)])
    });
  }
}
