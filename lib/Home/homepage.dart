import 'package:d1_wsf24_driver/Home/addride.dart';
import 'package:d1_wsf24_driver/Home/ridecard.dart';
import 'package:d1_wsf24_driver/Modal/driver_repo.dart';
import 'package:d1_wsf24_driver/Modal/ride_repo.dart';
import 'package:d1_wsf24_driver/Modal/vehicle_repo.dart';
import 'package:d1_wsf24_driver/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePush extends StatelessWidget {
  const HomePush({super.key, required this.user});

  final String? user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Navigator(
      onGenerateRoute: (settings) =>
          MaterialPageRoute(builder: (context) => Homepage(user: user)),
    ));
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key, required this.user});

  final String? user;

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Vehicle? car;
  List<Ride> ride = [];
  DateTime? dateFilter;
  bool _isLoading = false;

  final _originController = TextEditingController();
  final _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    final user = await Driver.fetchDriver(widget.user);
    car = await Vehicle.fetchVehicle(user.ownVehicle!);
    await _applyFilter();
    setState(() {
      _isLoading = true;
    });
  }

  Future<void> _applyFilter() async {
    ride = await Ride.getRide(car!);
    if (_originController.text.isNotEmpty) {
      ride = ride
          .where((ride) => ride.origin
              .toLowerCase()
              .contains(_originController.text.toLowerCase()))
          .toList();
    }
    if (_destinationController.text.isNotEmpty) {
      ride = ride
          .where((ride) => ride.destination
              .toLowerCase()
              .contains(_destinationController.text.toLowerCase()))
          .toList();
    }
    if (dateFilter != null) {
      ride = ride
          .where((ride) =>
              ride.date.year == dateFilter!.year &&
              ride.date.month == dateFilter!.month &&
              ride.date.day == dateFilter!.day)
          .toList();
    }
    setState(() {});
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _autoDesign(
      {required String hint,
      required TextEditingController controller,
      required FocusNode focusNode}) {
    return Padding(
      padding: EdgeInsets.all(5.sp),
      child: SizedBox(
        width: 150.sp,
        child: TextField(
          focusNode: focusNode,
          controller: controller,
          decoration: InputDecoration(
              filled: true,
              fillColor: ThemeProvider.lightColor,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              hintText: hint),
          onSubmitted: (value) {
            controller.text = value;
            _applyFilter();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Padding(
          padding: EdgeInsets.all(7.w),
          child: SingleChildScrollView(
            child: RefreshIndicator(
              onRefresh: getUserData,
              child: Column(children: [
                Container(
                  color: ThemeProvider.honeydew,
                  child: Column(children: [
                    SizedBox(height: 20.h),
                    Row(children: [
                      Column(children: [
                        Wrap(children: [
                          Autocomplete<Ride>(
                            optionsBuilder: (textValue) {
                              if (textValue.text.isEmpty) {
                                _originController.text = '';
                                return const Iterable<Ride>.empty();
                              }
                              return ride.where((ride) => ride.origin
                                  .toLowerCase()
                                  .contains(textValue.text.toLowerCase()));
                            },
                            displayStringForOption: (option) => option.origin,
                            onSelected: (ride) {
                              _originController.text = ride.origin;
                              _applyFilter();
                            },
                            fieldViewBuilder: (context, textEditingController,
                                    focusNode, onFieldSubmitted) =>
                                _autoDesign(
                              focusNode: focusNode,
                              hint: 'Origin...',
                              controller: textEditingController,
                            ),
                          ),
                          Autocomplete<Ride>(
                            optionsBuilder: (textValue) {
                              if (textValue.text.isEmpty) {
                                _destinationController.text = '';
                                return const Iterable<Ride>.empty();
                              }
                              return ride.where((ride) => ride.destination
                                  .toLowerCase()
                                  .contains(textValue.text.toLowerCase()));
                            },
                            displayStringForOption: (option) =>
                                option.destination,
                            onSelected: (ride) {
                              _destinationController.text = ride.destination;
                              _applyFilter();
                            },
                            fieldViewBuilder: (context, textEditingController,
                                    focusNode, onFieldSubmitted) =>
                                _autoDesign(
                                    focusNode: focusNode,
                                    hint: 'Destination...',
                                    controller: textEditingController),
                          ),
                        ]),
                        Wrap(children: [
                          SizedBox(
                            width: 200.sp,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: ThemeProvider.lightColor),
                                onPressed: () async {
                                  dateFilter = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2030));
                                  _applyFilter();
                                },
                                child: Text(dateFilter == null
                                    ? "Filter Date"
                                    : _formatDate(dateFilter!))),
                          ),
                          if (dateFilter != null)
                            IconButton(
                                onPressed: () => setState(() {
                                      dateFilter = null;
                                      _applyFilter();
                                    }),
                                icon: const Icon(Icons.cancel))
                        ])
                      ]),
                      ElevatedButton(
                        onPressed: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddRide(
                                        car: car!,
                                        isEdit: false,
                                        preride: null,
                                      )));
                          getUserData();
                        },
                        child: const Icon(Icons.add),
                      )
                    ]),
                  ]),
                ),
                SizedBox(height: 20.h),
                ride.isNotEmpty
                    ? SizedBox(
                        height: 510.h,
                        child: ListView.builder(
                            itemCount: ride.length,
                            itemBuilder: (context, index) {
                              final currentRide = ride[index];
                              return RideCard(
                                  ride: currentRide,
                                  vehicle: car!,
                                  refresh: getUserData);
                            }),
                      )
                    : Center(child: Text('No ride available'))
              ]),
            ),
          ),
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
