import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tut_two/pages/rides_list_page.dart';

class RideDetailsPage extends StatefulWidget {
  final String rideId;

  const RideDetailsPage({Key? key, required this.rideId}) : super(key: key);

  @override
  State<RideDetailsPage> createState() => _RideDetailsPageState();
}

class _RideDetailsPageState extends State<RideDetailsPage> {
  late DocumentSnapshot rideDocument;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRideDetails();
  }

  Future<void> _fetchRideDetails() async {
    try {
      final DocumentSnapshot rideSnapshot = await FirebaseFirestore.instance
          .collection('rides')
          .doc(widget.rideId)
          .get();

      setState(() {
        rideDocument = rideSnapshot;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching ride details: $e');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ride Details",
              style: TextStyle(fontSize: 20),
            )
          ],
        ),
        backgroundColor: Colors.amber[700],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _buildRideDetails(),
    );
  }

  Widget _buildRideDetails() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Origin: ${rideDocument['rideOrigin'][0]['description']}',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 8.0),
              Text(
                'Destination: ${rideDocument['rideDestination'][0]['description']}',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 8.0),
              Text(
                'Client Total: ${rideDocument['totalClientPays']}',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Discount: ${rideDocument['totalDeduction']}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              Text(
                'Driver Revenue: ${rideDocument['totalFareBeforeDeduction'] * 0.85}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RidesListPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700], // Background color
                    foregroundColor: Colors.grey[850], // Foreground color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(4.0), // Rounded corners
                    ),
                  ),
                  child: Text(
                    'New Rides',
                    style: TextStyle(
                      fontSize: 24, // Font size
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
