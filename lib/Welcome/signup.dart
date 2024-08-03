import 'dart:io';
import 'dart:math';
import 'package:d1_wsf24_driver/Modal/driver_repo.dart';
import 'package:d1_wsf24_driver/Welcome/verifypage.dart';
import 'package:d1_wsf24_driver/main.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formkey = GlobalKey<FormState>();
  final _formkey2 = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _icnumController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _gender = 'Male';

  int _stepperIndex = 0;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _requestPhotoPermission();
  }

  Widget textField(
      {required String hintext,
      required bool form,
      required TextEditingController controller,
      required Function(String) validate}) {
    return TextFormField(
      onChanged: (value) => form
          ? _formkey.currentState!.validate()
          : _formkey2.currentState!.validate(),
      controller: controller,
      decoration: InputDecoration(hintText: hintext),
      validator: (value) {
        return validate(value!);
      },
    );
  }

  Future<void> _requestPhotoPermission() async {
    await [Permission.mediaLibrary, Permission.photos, Permission.camera]
        .request();
  }

  Future<void> _pickImage(bool isCamera) async {
    final pickedfile = await ImagePicker()
        .pickImage(source: isCamera ? ImageSource.camera : ImageSource.gallery);

    if (pickedfile != null) {
      setState(() {
        _pickedImage = File(pickedfile.path);
      });
    }
  }

  Future<void> submitForm() async {
    if (await Driver.checkDupli(_icnumController.text, _phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('IC. Number or Phone Number already exist')));
    } else if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload an image')));
    } else if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      _formkey2.currentState!.save();

      final labelHead = WordPair.random();
      final labelEnd = Random().nextInt(100);

      final lastICdigit =
          _icnumController.text.substring(_icnumController.text.length - 1);
      int.parse(lastICdigit) % 2 == 0 ? _gender = 'Female' : _gender = 'Male';

      final newDriver = Driver(
          name: _nameController.text,
          icNumber: _icnumController.text,
          gender: _gender,
          phone: _phoneController.text,
          email: _emailController.text,
          password: _passwordController.text,
          address: _addressController.text,
          idLabel: '${labelHead.asPascalCase}$labelEnd');

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  VerifyPage(newDriver: newDriver, image: _pickedImage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeProvider.lightColor,
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(children: [
            SizedBox(
              height: 500.h,
              child: Stepper(
                  currentStep: _stepperIndex,
                  onStepCancel: () {
                    if (_stepperIndex > 0) {
                      setState(() {
                        _stepperIndex -= 1;
                      });
                    }
                  },
                  onStepContinue: () {
                    switch (_stepperIndex) {
                      case 0:
                        if (_formkey.currentState!.validate()) {
                          setState(() {
                            _stepperIndex += 1;
                          });
                          break;
                        }
                      case 1:
                        if (_formkey2.currentState!.validate()) {
                          setState(() {
                            _stepperIndex += 1;
                          });
                          break;
                        }
                      default:
                        submitForm();
                    }
                  },
                  onStepTapped: (value) => setState(() {
                        _stepperIndex = value;
                      }),
                  steps: [
                    Step(
                        title: const Icon(Icons.person),
                        content: Form(
                          key: _formkey,
                          child: Column(children: [
                            textField(
                                form: true,
                                hintext: 'Fill in your name...',
                                controller: _nameController,
                                validate: (value) => value.isNotEmpty
                                    ? null
                                    : 'Dont leave empthy'),
                            textField(
                                form: true,
                                hintext: 'IC number...(e.g 012345865432)',
                                controller: _icnumController,
                                validate: (value) => value.isNotEmpty &&
                                        RegExp(r'\d{12}$').hasMatch(value) &&
                                        value.length < 13
                                    ? null
                                    : 'invalid IC number'),
                            textField(
                                form: true,
                                hintext: 'Fill in your password...',
                                controller: _passwordController,
                                validate: (value) => value.isNotEmpty
                                    ? null
                                    : 'Dont leave empthy'),
                          ]),
                        )),
                    Step(
                        title: const Row(children: [
                          Icon(Icons.email),
                          Icon(Icons.phone),
                          Icon(Icons.location_city)
                        ]),
                        content: Form(
                          key: _formkey2,
                          child: Column(children: [
                            textField(
                                form: false,
                                hintext: 'Email... (e.g example@.gmail.com)',
                                controller: _emailController,
                                validate: (value) => value.isNotEmpty &&
                                        RegExp(r'^.+@.+').hasMatch(value)
                                    ? null
                                    : 'invalid email'),
                            textField(
                                form: false,
                                hintext: 'Phone number... (e.g 0169776743)',
                                controller: _phoneController,
                                validate: (value) => value.isNotEmpty &&
                                        RegExp(r'\d{10}$').hasMatch(value) &&
                                        value.length < 11
                                    ? null
                                    : 'invalid phone number'),
                            textField(
                                form: false,
                                hintext:
                                    'Address... (e.g Kuala Lumpur/Klang Lama)',
                                controller: _addressController,
                                validate: (value) => value.isNotEmpty
                                    ? null
                                    : 'Dont leave empthy'),
                          ]),
                        )),
                    Step(
                        title: const Icon(Icons.image),
                        content: Column(children: [
                          Row(children: [
                            ElevatedButton(
                                onPressed: () async {
                                  await _pickImage(false);
                                },
                                child: const Text('Gallery')),
                            ElevatedButton(
                                onPressed: () async {
                                  await _pickImage(true);
                                },
                                child: const Text('Camera'))
                          ]),
                          if (_pickedImage != null)
                            SizedBox(
                              height: 150.h,
                              width: 150.w,
                              child: Image.file(_pickedImage!),
                            )
                        ]))
                  ]),
            ),
          ]),
        ),
      ),
    );
  }
}
