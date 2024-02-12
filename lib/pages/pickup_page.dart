import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_tut_two/pages/end_ride_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class PickupPage extends StatefulWidget {
  final String rideId;

  const PickupPage({Key? key, required this.rideId}) : super(key: key);

  @override
  State<PickupPage> createState() => _PickupPageState();
}

class _PickupPageState extends State<PickupPage> {
  GoogleMapController? mapController;
  LatLng _center = const LatLng(-23.5557714, -46.6395571);
  late String pickupDescription = ''; // To store pickup description
  bool _mapLoaded = false;

  @override
  void initState() {
    super.initState();
    // Fetch ride data from Firestore
    FirebaseFirestore.instance
        .collection('rides')
        .doc(widget.rideId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        // Extract longitude and latitude
        var rideDoc = documentSnapshot.data()! as Map<String, dynamic>;
        double lng = rideDoc['rideOrigin'][0]['location']['lng'];
        double lat = rideDoc['rideOrigin'][0]['location']['lat'];
        _center = LatLng(lat, lng);

        // Set pickup description
        pickupDescription = rideDoc['rideOrigin'][0]['description'];

        // Update map
        if (mapController != null) {
          mapController!.moveCamera(CameraUpdate.newLatLng(_center));
        }
        setState(() {
          _mapLoaded = true; // Set _mapLoaded to true when map is loaded
        });
      } else {
        debugPrint("Did not find Document");
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pick Up Point",
              style: TextStyle(fontSize: 20),
            ),
            Text(
              pickupDescription,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Colors.amber[700],
      ),
      body: _mapLoaded
          ? Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 20.0,
                  ),
                  markers: {
                    // Add a marker at the pickup location
                    Marker(
                      markerId: const MarkerId('pickup'),
                      position: _center,
                      infoWindow: InfoWindow(
                        title: 'Pickup Point',
                        snippet: pickupDescription,
                      ),
                    ),
                  },
                ),
                // Positioned widget for the button
                Positioned(
                  bottom: 20, // Adjust the bottom padding as needed
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EndRidePage(rideId: widget.rideId),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        foregroundColor: Colors.grey[850],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Start Ride',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                              height: 4), // Adjust spacing between the texts
                          Text(
                            pickupDescription,
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child:
                  CircularProgressIndicator()), // Show loading indicator while map is loading
    );
  }
}
