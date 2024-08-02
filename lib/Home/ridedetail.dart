import 'dart:convert';
import 'dart:math';
import 'package:d1_wsf24_driver/Modal/ride_repo.dart';
import 'package:d1_wsf24_driver/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<dynamic> toJson(List<Offset> offset) {
  return offset.map((offset) => {'dx': offset.dx, 'dy': offset.dy}).toList();
}

List<Offset> fromJson(List<dynamic> json) {
  return json.map((json) => Offset(json['dx'], json['dy'])).toList();
}

class RideDetail extends StatefulWidget {
  const RideDetail({super.key, required this.ride, required this.time});

  final Ride ride;
  final String time;

  @override
  State<RideDetail> createState() => _RideDetailState();
}

class _RideDetailState extends State<RideDetail> with TickerProviderStateMixin {
  late AnimationController _animateControl;
  late Animation _scaleAnimation;

  late List<Offset> riderPosi;

  double cenX = 200.sp;
  double cenY = 300.sp;
  double radius = 160.sp;

  Future<void> _savePosition(List<Offset> offset) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonOffset = toJson(offset);
    await prefs.setString(widget.ride.label, jsonEncode(jsonOffset));
  }

  Future<void> _loadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonOffset = prefs.getString(widget.ride.label);

    if (jsonOffset != null) {
      final decoded = fromJson(jsonDecode(jsonOffset));
      final riderCount = widget.ride.rider?.length ?? 0;

      if (decoded.length > riderCount) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Rider has been altered')));
      } else {
        setState(() {
          riderPosi = decoded;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initPosition();
    _loadPosition();

    _animateControl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    _scaleAnimation =
        Tween<double>(begin: 1, end: 1.1).animate(_animateControl);
  }

  void _initPosition() {
    riderPosi = List.generate(widget.ride.rider?.length ?? 0, (index) {
      double angle = 2 * pi * index / widget.ride.rider!.length;
      return Offset(cenX + radius * cos(angle), cenY + radius * sin(angle));
    });
  }

  @override
  void dispose() {
    _animateControl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeProvider.honeydew,
      appBar: AppBar(
        title: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Text(widget.ride.origin),
          const Icon(Icons.arrow_forward, color: ThemeProvider.highlightColor),
          Text(widget.ride.destination)
        ]),
      ),
      body: Stack(children: [
        CustomPaint(
            size: Size(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height),
            painter: ConnectLine(riderPosi, cenX, cenY)),
        Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onLongPress: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Saved')));
                _savePosition(riderPosi);
              },
              onTap: () => setState(() {
                _initPosition();
              }),
              child: Container(
                height: 100.h,
                width: 150.w,
                color: ThemeProvider.popColor,
                child: Center(
                    child: Text(widget.time,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15.sp))),
              ),
            )),
        if (widget.ride.rider != null)
          for (int i = 0; i < widget.ride.rider!.length; i++)
            Positioned(
              left: riderPosi[i].dx - 40.sp,
              top: riderPosi[i].dy - 60.sp,
              child: AnimatedBuilder(
                animation: _animateControl,
                builder: (context, child) => Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Draggable(
                    feedback: Container(
                      width: 80.sp,
                      height: 80.sp,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          backgroundBlendMode: BlendMode.colorBurn,
                          color: ThemeProvider.highlightColor),
                    ),
                    onDragEnd: (details) {
                      setState(() {
                        riderPosi[i] =
                            Offset(details.offset.dx + 40, details.offset.dy);
                      });
                    },
                    child: Container(
                      width: 80.sp,
                      height: 80.sp,
                      decoration: const BoxDecoration(
                          color: ThemeProvider.highlightColor,
                          shape: BoxShape.circle),
                      child: Center(child: Text(widget.ride.rider![i])),
                    ),
                  ),
                ),
              ),
            )
      ]),
    );
  }
}

class ConnectLine extends CustomPainter {
  final List<Offset> riderPosition;
  final double centerX;
  final double centerY;

  ConnectLine(this.riderPosition, this.centerX, this.centerY);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;

    for (final position in riderPosition) {
      canvas.drawLine(Offset(centerX, centerY), position, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
