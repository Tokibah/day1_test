import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Driver {
  final String name;
  final String icNumber;
  final String gender;
  String phone;
  final String email;
  final String address;
  String? image;
  String? password;
  final String idLabel;
  DocumentReference? ownVehicle;

  Driver(
      {required this.name,
      required this.icNumber,
      required this.gender,
      required this.phone,
      required this.email,
      required this.address,
      this.image,
      this.password,
      this.ownVehicle,
      required this.idLabel});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icNumber': icNumber,
      'gender': gender,
      'phone': phone,
      'email': email,
      'address': address,
      'image': image,
      'password': password,
      'ownVehicle': ownVehicle,
      'idLabel': idLabel
    };
  }

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
        name: map['name'],
        icNumber: map['icNumber'],
        gender: map['gender'],
        phone: map['phone'],
        email: map['email'],
        address: map['address'],
        image: map['image'],
        password: map['password'],
        ownVehicle: map['ownVehicle'],
        idLabel: map['idLabel']);
  }

  static final _firestore = FirebaseFirestore.instance;

  static Future<Driver> fetchDriver(String? label) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      final collect = await _firestore.collection('Driver').doc(label).get();
      final map = collect.data() as Map<String, dynamic>;
      return Driver.fromMap(map);
    } catch (e) {
      print('ERROR FETCHDRIVER: $e');
      rethrow;
    }
  }

  static Future<void> addDriver(Driver driver, String anchor) async {
    try {
      final byte = utf8.encode(driver.password!);
      final hashed = sha256.convert(byte).toString();
      driver.password = hashed;

      final anVehicle = _firestore.collection('Vehicle').doc(anchor);
      driver.ownVehicle = anVehicle;

      await _firestore
          .collection('Driver')
          .doc(driver.idLabel)
          .set(driver.toMap());
    } catch (e) {
      print('ADDDRIVER ERROR: $e');
    }
  }

  static Future<void> uploadImage(File? image, String? label, String id) async {
    try {
      if (label != '' && label != null) {
        await FirebaseStorage.instance.refFromURL(label).delete();
      }
      final uploadTask = FirebaseStorage.instance
          .ref('images/${DateTime.now().microsecondsSinceEpoch}.jpg')
          .putFile(image!);

      final snapshot = await uploadTask;
      final dowloadUrl = await snapshot.ref.getDownloadURL();
      await _firestore
          .collection('Driver')
          .doc(id)
          .update({'image': dowloadUrl});
    } catch (e) {
      print('ERROR UPLOADIMAGE: $e');
    }
  }

  static Future<void> updateDriver(
      String name, String address, String label) async {
    try {
      await _firestore
          .collection('Driver')
          .doc(label)
          .update({'name': name, 'address': address});
    } catch (e) {
      print('ERROR UPDATEDRIVER: $e');
    }
  }

  static Future<String> logIn(String givenIc, String givenPass) async {
    final byte = utf8.encode(givenPass);
    final hash = sha256.convert(byte).toString();

    try {
      final collect = await _firestore
          .collection('Driver')
          .where('icNumber', isEqualTo: givenIc)
          .where('password', isEqualTo: hash)
          .get();

      if (collect.docs.isEmpty) {
        return '';
      }

      final logDriver = Driver.fromMap(collect.docs.first.data());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', logDriver.idLabel);

      return logDriver.idLabel;
    } catch (e) {
      print('LOGIN ERROR: $e');
      return '';
    }
  }

  static Future<bool> checkDupli(String newIc, String newPhone) async {
    final queries = [
      _firestore.collection('Driver').where('icNumber', isEqualTo: newIc).get(),
      _firestore.collection('Driver').where('phone', isEqualTo: newPhone).get(),
    ];

    final snap = await Future.wait(queries);

    return snap.any((querysnap) => querysnap.docs.isNotEmpty);
  }
}
