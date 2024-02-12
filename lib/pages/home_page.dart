import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tut_two/pages/rides_list_page.dart';
import 'package:flutter_tut_two/pages/update_profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tut_two/pages/menu_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? currentUserId;
  final user = FirebaseAuth.instance.currentUser!;
  DocumentSnapshot<Map<String, dynamic>>? driverData;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      getDriverData();
    }
  }

  Future<void> getDriverData() async {
    try {
      final driverDoc = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(currentUserId)
          .get();
      if (driverDoc.exists) {
        setState(() {
          driverData = driverDoc;
        });
      }
    } catch (e) {
      _showSnackbar('Failed to load driver data');
      debugPrint('No Driver Data Found');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mile Driver'),
        centerTitle: true,
        backgroundColor: Colors.amber[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (driverData != null && driverData!['profilePicture'] != null)
              CircleAvatar(
                radius: 100,
                backgroundImage: NetworkImage(driverData!['profilePicture']),
              ),
            const SizedBox(height: 10),
            Text('Signed In as: ${user.email}'),

            // Update Profile Button
            const SizedBox(height: 20),
            MaterialButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const RidesListPage();
                }));
              },
              color: Colors.amber[700],
              child: Text(
                'Check New Rides',
                style: TextStyle(fontSize: 20),
              ),
            ),

// Sign Out Button
            MaterialButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              color: Colors.red[700],
              child: const Text(
                'Sign Out',
                style: TextStyle(fontSize: 20),
              ),
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
