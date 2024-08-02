import 'dart:math';
import 'package:d1_wsf24_driver/Modal/ride_repo.dart';
import 'package:d1_wsf24_driver/Modal/vehicle_repo.dart';
import 'package:d1_wsf24_driver/main.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddRide extends StatefulWidget {
  const AddRide(
      {super.key,
      required this.car,
      required this.isEdit,
      required this.preride});

  final Vehicle car;
  final bool isEdit;
  final Ride? preride;

  @override
  State<AddRide> createState() => _AddRideState();
}

class _AddRideState extends State<AddRide> {
  final _formkey = GlobalKey<FormState>();

  List<String>? preDefine = [];
  DateTime? dateRide;
  TimeOfDay? timeRide;

  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _feeController = TextEditingController(text: 'RM0.00');

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _preData();
    }
  }

  void _preData() {
    final pretime = TimeOfDay(
        hour: widget.preride!.date.hour, minute: widget.preride!.date.minute);
    dateRide = widget.preride!.date;
    timeRide = pretime;

    _originController.text = widget.preride!.origin;
    _destinationController.text = widget.preride!.destination;
    _feeController.text = widget.preride!.fare;

    preDefine = widget.preride!.rider;
  }

  Future<void> addRide() async {
    final labelHead = WordPair.random();
    final labelTail = Random().nextInt(100);

    final combineDate = DateTime(dateRide!.year, dateRide!.month, dateRide!.day,
        timeRide!.hour, timeRide!.minute);
    final newRide = Ride(
        date: combineDate,
        origin: _originController.text,
        destination: _destinationController.text,
        fare: _feeController.text,
        rider: preDefine,
        label: '$labelHead$labelTail');

    await Ride.addRide(newRide, widget.isEdit, widget.preride?.label);
    if (!widget.isEdit) {
      await Vehicle.addRide(newRide.label, widget.car.vLabel);
    }
    Navigator.pop(context);
  }

  Future<String?> _showDialog() async {
    final predefineController = TextEditingController();
    return showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Enter Rider name:'),
                content: TextField(controller: predefineController),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('cancel',
                          style: TextStyle(color: Colors.black))),
                  TextButton(
                      onPressed: () =>
                          Navigator.pop(context, predefineController.text),
                      child: const Text(
                        'ADD',
                      ))
                ]));
  }

  void _formatFare(String text) {
    text = text.isEmpty ? "000" : text.replaceAll(RegExp(r'[\D]'), '');

    if (text.length > 3 && text.contains(RegExp(r'^0\d*'))) {
      text = text.replaceFirst('0', '');
    } else if (text.length < 3) {
      text = text.padLeft(3, '0');
    }

    _feeController.text =
        "RM${text.substring(0, text.length - 2)}.${text.substring(text.length - 2)}";
    setState(() {});
  }

  Widget _textField(
      {required String hint,
      required TextEditingController controller,
      required String label}) {
    return Padding(
      padding: EdgeInsets.all(8.sp),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label),
        SizedBox(
          width: 300.w,
          child: TextFormField(
              validator: (value) {
                return value == null || value.isEmpty
                    ? 'Dont leave empty'
                    : null;
              },
              decoration:
                  InputDecoration(hintText: hint, border: const OutlineInputBorder()),
              controller: controller),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Ride'),
      ),
      body: Center(
        child: Form(
          key: _formkey,
          child: SingleChildScrollView(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Wrap(spacing: 20.sp, children: [
                ElevatedButton(
                  onPressed: () async {
                    dateRide = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    setState(() {});
                  },
                  child: Text(dateRide != null
                      ? "${dateRide?.day}/${dateRide?.month}/${dateRide?.year}"
                      : 'Choose date'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    timeRide = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {});
                  },
                  child: Text(timeRide != null
                      ? '${timeRide?.format(context)}'
                      : 'Choose time'),
                ),
              ]),
              _textField(
                  hint: 'Where the starting point?',
                  controller: _originController,
                  label: "Origin"),
              _textField(
                  hint: 'Where will we stop?',
                  controller: _destinationController,
                  label: 'Destination'),
              const Divider(),
              const Text('Fare:'),
              SizedBox(
                  width: 300.w,
                  child: TextField(
                    controller: _feeController,
                    onChanged: _formatFare,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.center,
                  )),
              Padding(
                padding: EdgeInsets.all(10.sp),
                child:
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(
                    'Pre-define rider',
                    style: TextStyle(fontSize: 17.sp),
                  ),
                  IconButton(
                      onPressed: () async {
                        if (preDefine!.length < widget.car.capacity) {
                          final result = await _showDialog();
                          if (result != null && result.isNotEmpty) {
                            setState(() {
                              preDefine?.add(result);
                            });
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Reached max car capacity')));
                        }
                      },
                      icon: const Icon(Icons.add)),
                ]),
              ),
              Wrap(spacing: 10.sp, children: [
                for (int i = 0; i < preDefine!.length; i++)
                  GestureDetector(
                    onDoubleTap: () => setState(() {
                      preDefine?.removeAt(i);
                    }),
                    child: Container(
                      width: 150.w,
                      height: 40.h,
                      color: ThemeProvider.honeydew,
                      child: Center(
                          child: Text(preDefine![i],
                              overflow: TextOverflow.ellipsis)),
                    ),
                  )
              ]),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  if (dateRide == null || timeRide == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Set Date and Time properly')));
                  }
                  if (_formkey.currentState!.validate()) {
                    _formkey.currentState!.save();

                    addRide();
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeProvider.popColor),
                child: const Icon(Icons.add),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
