import 'dart:io';
import 'dart:math';
import 'package:d1_wsf24_driver/Modal/driver_repo.dart';
import 'package:d1_wsf24_driver/Modal/vehicle_repo.dart';
import 'package:d1_wsf24_driver/Welcome/launchpage.dart';
import 'package:d1_wsf24_driver/Welcome/loginpage.dart';
import 'package:d1_wsf24_driver/main.dart';
import 'package:d1_wsf24_driver/pagetransition.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VehicleSignUp extends StatefulWidget {
  const VehicleSignUp(this.seat,
      {super.key,
      required this.newDriver,
      this.car,
      required this.isEdit,
      required this.image});

  final Driver? newDriver;
  final Vehicle? car;
  final int seat;
  final File? image;
  final bool isEdit;

  @override
  State<VehicleSignUp> createState() => _VehicleSignUpState();
}

class _VehicleSignUpState extends State<VehicleSignUp> {
  final _formKey = GlobalKey<FormState>();

  final _carNameController = TextEditingController();
  final _specFeaturesController = TextEditingController();
  final _addreesController = TextEditingController();
  final _nameController = TextEditingController();
  double _seatCapacity = 2;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _predata();
    }
  }

  void _predata() {
    _carNameController.text = widget.car!.name;
    _specFeaturesController.text = widget.car!.specFeatures;
    _addreesController.text = widget.newDriver!.address;
    _nameController.text = widget.newDriver!.name;
    _seatCapacity = widget.car?.capacity ?? 2;
  }

  Future<void> _registerAll() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final labelHead = WordPair.random();
    final labelTail = Random().nextInt(100);

    final newVehicle = Vehicle(
      name: _carNameController.text,
      capacity: _seatCapacity,
      specFeatures: _specFeaturesController.text.trim(),
      vLabel: '${labelHead.asPascalCase}$labelTail',
    );

    await Vehicle.addVehicle(newVehicle);
    await Driver.addDriver(widget.newDriver!, newVehicle.vLabel);
    await Driver.uploadImage(widget.image, '', widget.newDriver!.idLabel);

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LaunchPage()));
    Navigator.push(context, SizeRoute(page: const LogInPage()));
  }

  Future<void> _update() async {
    if (_seatCapacity < widget.seat) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Seat capacity is lower than current ride')));
    } else {
      final newVehicle = Vehicle(
          vLabel: '',
          name: _carNameController.text,
          capacity: _seatCapacity,
          specFeatures: _specFeaturesController.text.trim());

      await Driver.updateDriver(_nameController.text, _addreesController.text,
          widget.newDriver!.idLabel);
      await Vehicle.updateVehicle(widget.car!.vLabel, newVehicle);
      Navigator.pop(context);
    }
  }

  Widget textField(
      {required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextFormField(
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderSide: BorderSide(width: 2),
            ),
          ),
          controller: controller,
          validator: (value) => value!.isEmpty ? 'Don\'t leave empty' : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(8.sp),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.isEdit)
                    Container(
                        child: Column(
                      children: [
                        textField(label: 'Name', controller: _nameController),
                        SizedBox(height: 20.h),
                        textField(
                            label: 'Address', controller: _addreesController),
                        const Divider(),
                      ],
                    )),
                  Text(
                    'Vehicle registration',
                    style: TextStyle(fontSize: 30.sp),
                  ),
                  SizedBox(height: 30.h),
                  textField(label: 'Car model', controller: _carNameController),
                  SizedBox(height: 10.h),
                  const Text('Seat Capacity'),
                  Slider(
                    max: 10,
                    divisions: 8,
                    label: _seatCapacity.toInt().toString(),
                    min: 2,
                    inactiveColor: Colors.grey,
                    value: _seatCapacity,
                    onChanged: (value) {
                      setState(() {
                        _seatCapacity = value;
                      });
                    },
                  ),
                  TextField(
                    controller: _specFeaturesController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Special features, e.g., wheelchair accessible',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeProvider.trustColor,
                    ),
                    onPressed: () {
                      if (widget.isEdit) {
                        _update();
                      } else {
                        _registerAll();
                      }
                    },
                    child: const Icon(Icons.add),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
