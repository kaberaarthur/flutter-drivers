import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_tut_two/pages/ride_details_page.dart';

class EndRidePage extends StatefulWidget {
  final String rideId;

  const EndRidePage({Key? key, required this.rideId}) : super(key: key);

  @override
  State<EndRidePage> createState() => _EndRidePageState();
}

class _EndRidePageState extends State<EndRidePage> {
  GoogleMapController? mapController;
  LatLng _center = const LatLng(-23.5557714, -46.6395571);
  LatLng? _destination;
  late String pickupDescription = ''; // To store pickup description
  late String dropoffDescription = ''; // To store dropoff description
  bool _mapLoaded = false;
  List<LatLng> _routePoints = [];

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

        double destlng = rideDoc['rideDestination'][0]['location']['lng'];
        double destlat = rideDoc['rideDestination'][0]['location']['lat'];
        _destination = LatLng(destlat, destlng);

        // Set pickup description
        pickupDescription = rideDoc['rideOrigin'][0]['description'];

        // Set dropoff description
        dropoffDescription = rideDoc['rideDestination'][0]['description'];

        // Fetch route between pickup and dropoff
        _fetchRoute().then((_) {
          if (mapController != null) {
            mapController!.moveCamera(CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(
                  _center.latitude < _destination!.latitude
                      ? _center.latitude
                      : _destination!.latitude,
                  _center.longitude < _destination!.longitude
                      ? _center.longitude
                      : _destination!.longitude,
                ),
                northeast: LatLng(
                  _center.latitude > _destination!.latitude
                      ? _center.latitude
                      : _destination!.latitude,
                  _center.longitude > _destination!.longitude
                      ? _center.longitude
                      : _destination!.longitude,
                ),
              ),
              100.0, // Padding
            ));
          }
          setState(() {
            _mapLoaded = true;
          });
        });
      } else {
        debugPrint("Did not find Document");
      }
    });
  }

  Future<void> _fetchRoute() async {
    final String apiKey =
        'AIzaSyD0kPJKSOU4qtXrvddyAZFHeXQY2LMrz_M'; // Replace with your Google Maps API key
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_center.latitude},${_center.longitude}&destination=${_destination!.latitude},${_destination!.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final decodedResponse = json.decode(response.body);

    if (decodedResponse['status'] == 'OK') {
      final List<dynamic> routes = decodedResponse['routes'];
      final List<dynamic> legs = routes[0]['legs'];
      final List<dynamic> steps = legs[0]['steps'];

      for (int i = 0; i < steps.length; i++) {
        final dynamic startLocation = steps[i]['start_location'];
        final dynamic endLocation = steps[i]['end_location'];
        _routePoints.add(LatLng(startLocation['lat'], startLocation['lng']));
        _routePoints.add(LatLng(endLocation['lat'], endLocation['lng']));
      }
    }
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
              "Drop Off",
              style: TextStyle(fontSize: 20),
            ),
            Text(
              dropoffDescription,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Colors.amber[700],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
            markers: {
              // Add a marker at the pickup location
              Marker(
                markerId: const MarkerId('pickup'),
                position: _center,
                // Custom info window that's always visible
                infoWindow: InfoWindow(
                  title: 'Pickup Point',
                  snippet: pickupDescription,
                  anchor: Offset(0.5, 0.5),
                  onTap:
                      () {}, // Prevents the default behavior of hiding on tap
                ),
              ),
              // Add a marker at the destination
              Marker(
                markerId: const MarkerId('destination'),
                position: _destination!,
                // Custom info window that's always visible
                infoWindow: InfoWindow(
                  title: 'Drop Off Point',
                  snippet: dropoffDescription,
                  anchor: Offset(0.5, 0.5),
                  onTap:
                      () {}, // Prevents the default behavior of hiding on tap
                ),
              ),
            },
            polylines: {
              Polyline(
                polylineId: const PolylineId('route'),
                color: Colors.blue,
                points: _routePoints,
                width: 5,
              ),
            },
          ),
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
                          RideDetailsPage(rideId: widget.rideId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: Colors.grey[850],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Column(
                  children: [
                    Text(
                      'End Ride',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
