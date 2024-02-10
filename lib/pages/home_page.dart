import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tut_two/pages/map_page.dart';
import 'package:flutter_tut_two/pages/ride_data_page.dart';
import 'package:flutter_tut_two/pages/update_profile_page.dart';

import 'package:flutter_tut_two/pages/menu_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Signed In as: ${user.email}'),

            // Sign Out Button
            MaterialButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              color: Colors.amber[700],
              child: const Text('Sign Out'),
            ),

            // Update Profile Button
            MaterialButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const UpdateProfilePage();
                }));
              },
              color: Colors.amber[700],
              child: const Text('Update Profile'),
            ),

            // Map Page
            MaterialButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const RideDataPage();
                }));
              },
              color: Colors.amber[700],
              child: const Text('Ride Data'),
            ),

            // Constants Page
            MaterialButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const MapPage();
                }));
              },
              color: Colors.amber[700],
              child: const Text('Map Page'),
            ),

            // Menu Page
            MaterialButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const MenuPage();
                }));
              },
              color: Colors.amber[700],
              child: const Text('Menu Page'),
            )
          ],
        ),
      ),
    );
  }
}
