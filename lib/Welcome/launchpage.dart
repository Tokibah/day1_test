import 'package:d1_wsf24_driver/main.dart';
import 'package:d1_wsf24_driver/pagetransition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'loginpage.dart';
import 'signup.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});

  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 40))
          ..repeat(reverse: true);
    _slideAnimation =
        Tween(begin: const Offset(-3, 0), end: const Offset(1, 0)).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeProvider.honeydew,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'KONGSI\nKERETA\nDRIVER',
            textAlign: TextAlign.center,
            style: TextStyle(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dashed,
              decorationColor: ThemeProvider.popColor,
              decorationThickness: 2,
              fontSize: 30.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 60.h),
          SlideTransition(
            position: _slideAnimation,
            child: SizedBox(
              height: 200.h,
              child: Wrap(
                direction: Axis.vertical,
                runSpacing: 20.h,
                children: List.generate(
                    10, (index) => const FaIcon(FontAwesomeIcons.carSide, size: 150)),
              ),
            ),
          ),
          Text(
            'Enjoy your free hassle journey',
            style: TextStyle(fontSize: 25.sp),
          ),
          SizedBox(height: 40.h),
          SizedBox(
            width: 250.w,
            height: 50.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeProvider.trustColor),
              onPressed: () {
                Navigator.push(context, SizeRoute(page: const SignUpPage()));
              },
              child: Text(
                'SIGN UP',
                style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.w400),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context, SizeRoute(page: const LogInPage()));
            },
            child: Text(
              'Log in',
              style: TextStyle(fontSize: 20.sp, color: Colors.black38),
            ),
          ),
        ],
      ),
    );
  }
}
