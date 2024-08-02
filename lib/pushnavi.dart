import 'package:d1_wsf24_driver/Home/homepage.dart';
import 'package:d1_wsf24_driver/Home/profile.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PushNavigation extends StatefulWidget {
  const PushNavigation({super.key, required this.user});

  final String? user;

  @override
  State<PushNavigation> createState() => _PushNavigationState();
}

class _PushNavigationState extends State<PushNavigation> {
  int _selectedIndex = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [HomePush(user: widget.user), Profile(userId: widget.user)],
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
              icon: FaIcon(FontAwesomeIcons.car), label: 'Ride'),
          NavigationDestination(
              icon: FaIcon(FontAwesomeIcons.person), label: 'Profile')
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) => setState(() {
          _selectedIndex = value;
        }),
      ),
    );
  }
}
