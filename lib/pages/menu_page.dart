import 'package:flutter/material.dart';
import 'package:flutter_tut_two/pages/add_vehicle_page.dart';
import 'package:flutter_tut_two/pages/documents_page.dart';
import 'package:flutter_tut_two/pages/my_vehicles_page.dart';
import 'package:flutter_tut_two/pages/notifications_page.dart';
import 'package:flutter_tut_two/pages/rides_list_page.dart';
import 'package:flutter_tut_two/pages/update_profile_page.dart';
import 'package:flutter_tut_two/pages/messages_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        centerTitle: true,
        backgroundColor: Colors.amber[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Add your hamburger menu functionality here
              debugPrint('Hamburger menu pressed');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              menuItem(context, Icons.directions_car, 'Messages',
                  'Chat with rider', MessagesPage()),
              const SizedBox(height: 16.0),
              menuItem(context, Icons.directions_car, 'Rides', 'See new rides',
                  RidesListPage()),
              const SizedBox(height: 16.0),
              menuItem(context, Icons.person_add, 'Profile', 'Update Profile',
                  const UpdateProfilePage()),
              const SizedBox(height: 16.0),
              menuItem(context, Icons.credit_card, 'Finances', 'View Finances',
                  const UpdateProfilePage()), // Replace with your page
              const SizedBox(height: 16.0),
              menuItem(
                  context,
                  Icons.upload_file_rounded,
                  'Documents',
                  'Personal Documents',
                  const DocumentsPage()), // Replace with your page
              const SizedBox(height: 16.0),
              menuItem(context, Icons.car_rental_sharp, 'Add Vehicle',
                  'List a New Vehicle', const AddVehiclePage()),
              const SizedBox(height: 16.0),
              menuItem(context, Icons.list, 'My Vehicles', 'My Vehicles List',
                  const MyVehiclesPage()),
              const SizedBox(height: 16.0),
              menuItem(context, Icons.notification_add, 'Notifications',
                  'Recent Updates', NotificationsPage()),
            ],
          ),
        ),
      ),
    );
  }

  Widget menuItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Widget pageToNavigate,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => pageToNavigate),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        foregroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              size: 36.0,
            ),
            const SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                Text(description),
                Divider(height: 1.0, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
