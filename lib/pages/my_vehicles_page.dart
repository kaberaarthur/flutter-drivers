import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyVehiclesPage extends StatefulWidget {
  const MyVehiclesPage({Key? key}) : super(key: key);

  @override
  State<MyVehiclesPage> createState() => _MyVehiclesPageState();
}

class _MyVehiclesPageState extends State<MyVehiclesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicle'),
        backgroundColor: Colors.amber[700],
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vehicles')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No vehicles found'));
          } else {
            final vehicleData = snapshot.data!.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.all(16.0),
              child: ListTile(
                title: Text('Brand: ${vehicleData['brand']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Model: ${vehicleData['model']}'),
                    Text('Year: ${vehicleData['year']}'),
                    Text('License Plate: ${vehicleData['licensePlate']}'),
                    Text('Vehicle Color: ${vehicleData['color']}'),
                    Text('Approved: ${vehicleData['approved']}'),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
