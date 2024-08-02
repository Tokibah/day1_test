import 'package:d1_wsf24_driver/Home/addride.dart';
import 'package:d1_wsf24_driver/Home/ridedetail.dart';
import 'package:d1_wsf24_driver/Modal/ride_repo.dart';
import 'package:d1_wsf24_driver/Modal/vehicle_repo.dart';
import 'package:d1_wsf24_driver/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RideCard extends StatefulWidget {
  const RideCard(
      {super.key,
      required this.ride,
      required this.vehicle,
      required this.refresh});

  final Ride ride;
  final Vehicle vehicle;
  final Function() refresh;

  @override
  State<RideCard> createState() => _RideCardState();
}

class _RideCardState extends State<RideCard> {
  String time = '';

  void _formatdate() {
    final pretime =
        TimeOfDay(hour: widget.ride.date.hour, minute: widget.ride.date.minute);
    time =
        '${widget.ride.date.day}/${widget.ride.date.month}/${widget.ride.date.year} ${pretime.format(context)}';
  }

  Future<void> _deleteConfirm(context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('No')),
          TextButton(
              onPressed: () async {
                await Ride.deleteRide(widget.ride.label, widget.vehicle.vLabel);
                widget.refresh();
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Yes'))
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _formatdate();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5.sp),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), border: Border.all()),
      height: 120.h,
      child: Row(children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(5.sp),
            child: Container(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Text(widget.ride.origin),
                  const Icon(Icons.arrow_downward),
                  Text(widget.ride.destination),
                  const Divider(
                    color: Colors.grey,
                  ),
                  Row(children: [
                    Text(
                        'Capacity: ${widget.ride.rider?.length ?? '0'}/${widget.vehicle.capacity.toInt()}'),
                    const Spacer(),
                    Text(
                      time,
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          backgroundColor: ThemeProvider.popColor),
                    )
                  ])
                ])),
          ),
        ),
        Container(
          color: ThemeProvider.honeydew,
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      onPressed: () async {
                        await widget.refresh();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    RideDetail(ride: widget.ride, time: time)));
                      },
                      child: const Text('DETAIL')),
                  TextButton(
                      onPressed: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddRide(
                                    car: widget.vehicle,
                                    isEdit: true,
                                    preride: widget.ride)));
                        await widget.refresh();
                      },
                      child: const Text("EDIT")),
                  TextButton(
                      onPressed: () => _deleteConfirm(context),
                      child: Text(
                        'DELETE',
                        style: TextStyle(
                            color: Colors.red,
                            backgroundColor: Colors.red[100]),
                      ))
                ]),
          ),
        )
      ]),
    );
  }
}
