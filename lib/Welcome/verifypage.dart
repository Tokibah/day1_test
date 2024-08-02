import 'dart:io';
import 'package:d1_wsf24_driver/Modal/driver_repo.dart';
import 'package:d1_wsf24_driver/Welcome/vehicle_signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyPage extends StatefulWidget {
  const VerifyPage({super.key, required this.newDriver, required this.image});

  final Driver newDriver;
  final File? image;

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  @override
  Widget build(BuildContext context) {
    bool isPhone = false;
    final otpController = TextEditingController();
    String? verifyId;
    final fireAuth = FirebaseAuth.instance;

    Future<void> sendVerificationEmail() async {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: widget.newDriver.email, password: widget.newDriver.password!);
      await fireAuth.currentUser?.sendEmailVerification();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Email verifivation sent')));
    }

    Future<void> verifyPhoneNumber() async {
      fireAuth.verifyPhoneNumber(
          phoneNumber: widget.newDriver.phone,
          verificationCompleted: (cred) async {
            await fireAuth.signInWithCredential(cred);
          },
          verificationFailed: (e) {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: const Text('Phone verification fail'),
                      content: Text('$e'),
                    ));
          },
          codeSent: (verifyid, _) {
            verifyId = verifyid;
          },
          codeAutoRetrievalTimeout: (verifyid) {
            verifyId = verifyid;
          });
    }

    Future<void> verifyOTP() async {
      try {
        if (isPhone) {
          final cred = PhoneAuthProvider.credential(
              verificationId: verifyId!, smsCode: otpController.text);

          await fireAuth.signInWithCredential(cred);
        } else {
          if (fireAuth.currentUser!.emailVerified) {}
        }
      } catch (e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Verification fail'),
                  content: Text('$e'),
                ));
      }
    }

    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [
        const Text('Choose either one to verify your account'),
        ElevatedButton(
            onPressed: () {
              isPhone = false;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VehicleSignUp(
                            0,
                            newDriver: widget.newDriver,
                            isEdit: false,
                            image: widget.image,
                          )));
            },
            child: const Text('Email')),
        ElevatedButton(
            onPressed: () {
              isPhone = true;
              verifyPhoneNumber();
            },
            child: const Text('Phone')),
        if (isPhone)
          Column(children: [
            TextField(
                controller: otpController,
                decoration: const InputDecoration(hintText: 'Enter OTP')),
            ElevatedButton(onPressed: () {}, child: const Text('Verify OTP'))
          ]),
      ]),
    );
  }
}
