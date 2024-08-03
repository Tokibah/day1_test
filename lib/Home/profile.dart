import 'dart:io';
import 'package:d1_wsf24_driver/Modal/driver_repo.dart';
import 'package:d1_wsf24_driver/Modal/ride_repo.dart';
import 'package:d1_wsf24_driver/Modal/vehicle_repo.dart';
import 'package:d1_wsf24_driver/Welcome/launchpage.dart';
import 'package:d1_wsf24_driver/Welcome/vehicle_signup.dart';
import 'package:d1_wsf24_driver/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key, required this.userId});

  final userId;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int seatCount = 0;
  Vehicle? car;
  late Driver user;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    user = await Driver.fetchDriver(widget.userId);
    car = await Vehicle.fetchVehicle(user.ownVehicle!);
    final ride = await Ride.getRide(car!);
    ride.sort((a, b) => (b.rider?.length ?? 0).compareTo(a.rider?.length ?? 0));
    seatCount = ride[0].rider!.length;

    setState(() {
      isLoading = true;
    });
  }

  void _updatePicture(bool isCamera) async {
    final pickedImage = await ImagePicker()
        .pickImage(source: isCamera ? ImageSource.camera : ImageSource.gallery);
    if (pickedImage != null) {
      await Driver.uploadImage(
          File(pickedImage.path), user.image, widget.userId!);

      _getUserData();
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LaunchPage()),
    );
  }

  Widget optionContainer(
      {required String label,
      required Color? color,
      required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          height: 40.h,
          width: double.infinity,
          decoration: BoxDecoration(
              color: color,
              border: const Border.symmetric(horizontal: BorderSide(width: 1))),
          child: Align(alignment: Alignment.center, child: Text(label))),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
          backgroundColor: ThemeProvider.honeydew,
          body: Column(children: [
            SizedBox(height: 100.sp),
            Expanded(
              child: Container(
                width: double.infinity,
                color: ThemeProvider.lightColor,
                child: Column(children: [
                  SizedBox(height: 20.h),
                  GestureDetector(
                    onTap: () => showModalBottomSheet(
                        context: context,
                        builder: (context) => Wrap(children: [
                              ListTile(
                                  onTap: () => _updatePicture(true),
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text('Camera')),
                              ListTile(
                                  onTap: () => _updatePicture(false),
                                  leading: const Icon(Icons.image),
                                  title: const Text('Gallery')),
                            ])),
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: NetworkImage(user.image!),
                    ),
                  ),
                  Text(user.name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20.sp)),
                  Text(user.icNumber),
                  Expanded(
                    child: Scrollbar(
                      trackVisibility: true,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: Column(children: [
                          ListTile(
                              leading: const Icon(Icons.email),
                              title: Text(user.email)),
                          ListTile(
                              leading: const Icon(Icons.phone),
                              title: Text(user.phone)),
                          ListTile(
                              leading: const Icon(Icons.pin_drop),
                              title: Text(user.address)),
                          ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(user.gender)),
                          const Divider(),
                          ListTile(
                              leading: const FaIcon(FontAwesomeIcons.car),
                              title: Text(
                                  '${car?.name} (${car?.capacity.toInt()} seat)')),
                          Text('-${car?.specFeatures}'),
                          SizedBox(height: 20.h),
                          optionContainer(
                              label: 'EDIT',
                              color: Colors.blue[100],
                              onTap: () async {
                                await _getUserData();
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => VehicleSignUp(
                                            seatCount,
                                            newDriver: user,
                                            car: car,
                                            isEdit: true,
                                            image: null,
                                          )),
                                );
                                _getUserData();
                              }),
                          optionContainer(
                              label: 'LOGOUT',
                              color: Colors.red[100],
                              onTap: _logout)
                        ]),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ]));
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
