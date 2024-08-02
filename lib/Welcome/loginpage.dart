import 'package:d1_wsf24_driver/Modal/driver_repo.dart';
import 'package:d1_wsf24_driver/main.dart';
import 'package:d1_wsf24_driver/pushnavi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final _formKey = GlobalKey<FormState>();
  final _icController = TextEditingController();
  final _passController = TextEditingController();

  bool _logged = false;

  Future<void> _login() async {
    final logvalid =
        await Driver.logIn(_icController.text, _passController.text);
    if (logvalid == '') {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid account')));
    } else {
      setState(() {
        _logged = true;
      });
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => PushNavigation(user: logvalid)));
    }
  }

  Widget _textField(
      {required String label,
      required TextEditingController controller,
      required bool obscure}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label),
      TextFormField(
        obscureText: obscure,
        controller: controller,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Don\'t leave empty';
          }
          return null;
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeProvider.honeydew,
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.all(20.sp),
            child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  size: 40.sp,
                )),
          ),
          SizedBox(height: 50.h),
          Padding(
            padding: EdgeInsets.all(10.sp),
            child: const Text('L O G I N',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                )),
          ),
          SizedBox(height: 100.h),
          Align(
            alignment: Alignment.center,
            child: AnimatedOpacity(
              opacity: _logged ? 1 : 0,
              duration: const Duration(seconds: 1),
              child: Text(
                'WELCOME BACK',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: ThemeProvider.lightColor,
                borderRadius: BorderRadius.circular(40)),
            height: 350.sp,
            width: double.infinity,
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(8.sp),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _textField(
                          controller: _icController,
                          label: 'IC Number',
                          obscure: false),
                      _textField(
                          controller: _passController,
                          label: 'Password',
                          obscure: true),
                      Padding(
                        padding: EdgeInsets.all(10.sp),
                        child: SizedBox(
                          height: 50.h,
                          width: 100.w,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeProvider.highlightColor,
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _login();
                              }
                            },
                            child: Icon(
                              Icons.arrow_circle_right_outlined,
                              size: 40.sp,
                            ),
                          ),
                        ),
                      ),
                    ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
